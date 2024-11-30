//
//  ConnectionReactor.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import Foundation
import RxFlow
import ReactorKit
import Synology
import JustFoundation

// MARK: - ConnectionReactor

final class ConnectionReactor: SceneReactor {
  let initialState = State()

  func mutate(action: Action, continuation: MutationStreamContinuation) async throws {
    switch action {
    case .updateAddress(let address):
      continuation.yield(.setAddress(address.trimmingCharacters(in: .whitespaces)))

    case .connect:
      guard !currentState.isLoading && !currentState.address.isEmpty else {
        return
      }
      continuation.yield(.setLoading(true))
      defer {
        continuation.yield(.setLoading(false))
      }
      do {
        let connection = try await _connect(address: currentState.address)
        continuation.yield(.connectDidComplete)
        steps.accept(AppStep.login(connection: connection, isReauthentication: false))
      } catch {
        continuation.yield(.connectDidFail(error))
      }

    case .help:
      steps.accept(AppStep.knowledgeCenter(.quickConnect))

    case .cancel:
      steps.accept(AppStep.connectionCanceled)
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setAddress(let address):
      return state.mutate {
        $0.address = address
      }

    case .setLoading(let isLoading):
      return state.mutate {
        $0.isLoading = isLoading
      }

    case .connectDidComplete:
      return state.mutate {
        $0.connectCompleted = .success(())
      }

    case .connectDidFail(let error):
      return state.mutate {
        $0.connectCompleted = .failure(error)
      }
    }
  }
}

// MARK: - ConnectionReactor (Private)

extension ConnectionReactor {
  private func _connect(address: String) async throws -> Connection {
    if let serverURL = URL(string: address), let scheme = serverURL.scheme?.lowercased(), scheme.hasPrefix("http") {
      do {
        let pingPong = PingPoing()
        let pong = try await pingPong.ping(to: serverURL)
        guard pong.success else {
          throw DSMError.unableToConnectServer(address)
        }
        return Connection(diskStation: DiskStation(serverURL: serverURL))
      } catch {
        throw DSMError.unableToConnectServer(address)
      }
    } else {
      do {
        let quickConnect = QuickConnect()
        let diskStation = try await quickConnect.connect(id: address)
        return Connection(name: address, diskStation: diskStation)
      } catch {
        throw DSMError.cannotFindQuickConnectID(address)
      }
    }
  }
}

// MARK: - ConnectionReactor.State

extension ConnectionReactor {
  struct State: Then {
    var address: String = ""
    var isLoading: Bool = false

    @Pulse var connectCompleted: Result<Void, Error>?
  }
}

// MARK: - ConnectionReactor.Action

extension ConnectionReactor {
  enum Action {
    case updateAddress(String)
    case connect
    case help
    case cancel
  }
}

// MARK: - ConnectionReactor.Mutation

extension ConnectionReactor {
  enum Mutation {
    case setAddress(String)
    case setLoading(Bool)
    case connectDidComplete
    case connectDidFail(Error)
  }
}
