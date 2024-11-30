//
//  LoginReactor.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import Foundation
import JustFoundation
import RxFlow
import ReactorKit
import Synology

// MARK: - LoginReactor

final class LoginReactor: SceneReactor {
  let connection: Connection
  let keychain: AuthKeychain

  let initialState: State

  init(connection: Connection, keychain: AuthKeychain, isReauthentication: Bool) {
    self.connection = connection
    self.keychain = keychain
    self.initialState = State(supportsRememberMe: !isReauthentication)
  }

  func mutate(action: Action, continuation: MutationStreamContinuation) async throws {
    switch action {
    case .updateAccount(let account):
      continuation.yield(.setAccount(account))

    case .updatePassword(let password):
      continuation.yield(.setPassword(password))

    case .login:
      guard !currentState.account.isEmpty && !currentState.password.isEmpty else {
        return
      }
      continuation.yield(.setLoading(true))
      defer {
        continuation.yield(.setLoading(false))
      }

      let account = currentState.account
      let password = currentState.password
      let rememberMe = currentState.rememberMe
      do {
        let authorization = try await connection.ds.auth().login(
          account: account,
          password: password,
          deviceID: keychain.deviceID(for: connection.uuid)
        )
        continuation.yield(.loginDidComplete)
        steps.accept(
          AppStep.loginCompleted(
            connection: connection,
            authorization: authorization,
            savesSessionID: rememberMe,
            savesDeviceID: false
          )
        )
      } catch let error as AuthError where error == .noSuchAccountOrIncorrectPassword {
        continuation.yield(.loginDidFail)
      } catch let error as AuthError where error == .requiredTwoFactorAuthenticationCode {
        steps.accept(AppStep.twoFactorAuthentication(connection: connection, account: account, password: password, savesSessionID: rememberMe))
      }

    case .showsPassword(let isShown):
      continuation.yield(.setShowsPassword(isShown))

    case .rememberMe(let rememberMe):
      continuation.yield(.setRememberMe(rememberMe))

    case .help:
      steps.accept(AppStep.knowledgeCenter(.forgotPassword))

    case .cancel:
      steps.accept(AppStep.loginCanceled)
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setAccount(let account):
      return state.mutate {
        $0.account = account
      }

    case .setPassword(let password):
      return state.mutate {
        $0.password = password
      }

    case .setShowsPassword(let showsPassword):
      return state.mutate {
        $0.showsPassword = showsPassword
      }

    case .setRememberMe(let rememberMe):
      return state.mutate {
        $0.rememberMe = rememberMe
      }

    case .setLoading(let isLoading):
      return state.mutate {
        $0.isLoading = isLoading
      }

    case .loginDidComplete:
      return state.mutate {
        $0.loginCompleted = true
      }

    case .loginDidFail:
      return state.mutate {
        $0.loginCompleted = false
      }
    }
  }
}

// MARK: - LoginReactor.State

extension LoginReactor {
  struct State: Then {
    var account: String = ""
    var password: String = ""
    var showsPassword: Bool = false
    var rememberMe: Bool = true
    var supportsRememberMe: Bool
    var isLoading: Bool = false

    @Pulse var loginCompleted: Bool?
  }
}

// MARK: - LoginReactor.Action

extension LoginReactor {
  enum Action {
    case updateAccount(String)
    case updatePassword(String)
    case login
    case showsPassword(Bool)
    case rememberMe(Bool)
    case help
    case cancel
  }
}

// MARK: - LoginReactor.Mutation

extension LoginReactor {
  enum Mutation {
    case setAccount(String)
    case setPassword(String)
    case setShowsPassword(Bool)
    case setRememberMe(Bool)
    case setLoading(Bool)
    case loginDidComplete
    case loginDidFail
  }
}
