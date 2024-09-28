//
//  SceneReactor.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import ReactorKit
import Synology

// MARK: - SceneReactor

protocol SceneReactor: Reactor, Stepper {
  typealias MutationStreamContinuation = AsyncThrowingStream<Mutation, Swift.Error>.Continuation

  var retryPolicy: RetryPolicy { get }
  func mutate(action: Action, continuation: MutationStreamContinuation) async throws
}

// MARK: - SceneReactor (Default Implementation)

extension SceneReactor {
  var diskStation: DiskStation? { nil }
  var retryPolicy: RetryPolicy { .none }

  func transform(state: Observable<State>) -> Observable<State> {
    state.observe(on: MainScheduler.instance)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    #if DEBUG
    guard !ProcessInfo.processInfo.isPreview else {
      return .empty()
    }
    #endif

    Log.debug("↪️ \(String(describing: self)) - \(action)")
    let observable = Observable<Mutation>.create { [weak self] observer in
      guard let self else {
        return Disposables.create()
      }
      let stream = AsyncThrowingStream<Mutation, Error> { continuation in
        Task {
          do {
            try await self.mutate(action: action, continuation: continuation)
            continuation.finish()
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }
      let task = Task {
        do {
          for try await mutation in stream {
            observer.on(.next(mutation))
          }
          observer.on(.completed)
        } catch {
          observer.on(.error(error))
        }
      }
      return Disposables.create {
        task.cancel()
      }
    }

    let onError: (Error) -> Void = { [weak steps] in
      // steps?.accept(AppStep.notification(title: "Error", message: $0.localizedDescription, type: .error))
      Log.error($0.localizedDescription)
    }
    switch retryPolicy {
    case .whenAuthError(let connection):
      return observable
        .retry { [weak steps] in
          $0.flatMap { [weak steps] in
            guard let error = $0 as? DiskStationError else {
              return Observable<Void>.error($0)
            }
            switch error {
            case .sidNotFound:
              if let steps {
                steps.accept(AppStep.login(connection: connection, isReauthentication: true))
                // return NotificationCenter.default.rx.notification(.dsmLoginCompleted).map()
              }
              return .error(error)
            default:
              return .error(error)
            }
          }
        }
        .retry { [weak steps] in
          $0.flatMap { [weak steps] in
            guard let error = $0 as? NetworkingError else {
              return Observable<Void>.error($0)
            }
            guard case .sessionTaskFailed(let taskError) = error else {
              return .error(error)
            }
            guard let urlError = taskError as? URLError else {
              return .error(error)
            }
            return Observable.error(error)
          }
        }
        .do(onError: onError)
    case .none:
      return observable.do(onError: onError)
    }
  }
}

// MARK: - RetryPolicy

enum RetryPolicy {
  case whenAuthError(Connection)
  case none
}
