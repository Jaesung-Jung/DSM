//
//  IntroReactor.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import RxSwift
import RxFlow
import ReactorKit
import JustFoundation

// MARK: - IntroReactor

final class IntroReactor: SceneReactor {
  typealias Mutation = NoMutation

  let initialState = State()

  func mutate(action: Action, continuation: MutationStreamContinuation) async throws {
    switch action {
    case .connection:
      steps.accept(AppStep.connection)
    }
  }
}

// MARK: - IntroReactor.State

extension IntroReactor {
  struct State: Then {
  }
}

// MARK: - IntroReactor.Action

extension IntroReactor {
  enum Action {
    case connection
  }
}
