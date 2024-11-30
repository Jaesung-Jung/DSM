//
//  ConnectionFlow.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import UIKit
import RxFlow
import RxSwift
import Synology

// MARK: - ConnectionFlow

final class ConnectionFlow: Flow {
  let quickConnect = QuickConnect()
  let connectionManager: ConnectionManager

  let navigationController = UINavigationController().then {
    $0.navigationBar.prefersLargeTitles = true
  }

  var root: Presentable { navigationController }

  init(connectionManager: ConnectionManager) {
    self.connectionManager = connectionManager
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else {
      return .none
    }
    switch step {
    case .connection:
      let reactor = ConnectionReactor()
      let viewController = ConnectionViewController(reactor: reactor)
      navigationController.pushViewController(viewController, animated: true)
      return .one(
        flowContributor: .contribute(
          withNextPresentable: viewController,
          withNextStepper: reactor
        )
      )

//    case .login:
//      let flow = LoginFlow(keychain: connectionManager.keychain, navigationController: navigationController)
//      return .one(
//        flowContributor: .contribute(
//          withNextPresentable: flow,
//          withNextStepper: OneStepper(withSingleStep: step)
//        )
//      )
//
//    case .loginCompleted(let connection, _, let savesSessionID, _):
//      if savesSessionID {
//        connectionManager.appendConnection(connection)
//      }
//      navigationController.dismiss(animated: true)
//      return .end(forwardToParentFlowWithStep: AppStep.connectionCompleted(connection: connection))
//
//    case .loginCanceled, .connectionCanceled:
//      navigationController.dismiss(animated: true)
//      return .end(forwardToParentFlowWithStep: AppStep.connectionCanceled)

    default:
      return .one(flowContributor: .forwardToParentFlow(withStep: step))
    }
  }
}
