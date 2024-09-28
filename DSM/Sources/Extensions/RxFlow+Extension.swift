//
//  RxFlow+Extension.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

#if canImport(RxFlow) && canImport(RxRelay)

import Foundation
import RxFlow
import RxRelay

private var __stepsRelayAssoicatedKey: UInt8 = 0

extension Stepper where Self: AnyObject {
  var steps: PublishRelay<Step> {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }
    if let object = objc_getAssociatedObject(self, &__stepsRelayAssoicatedKey) as? PublishRelay<Step> {
      return object
    }
    let newObject = PublishRelay<Step>()
    objc_setAssociatedObject(self, &__stepsRelayAssoicatedKey, newObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return newObject
  }
}

extension FlowContributor {
  static func contribute<Scene: SceneViewController<Reactor>, Reactor: SceneReactor>(with scene: Scene) -> FlowContributor {
    guard let reactor = scene.reactor else {
      return .contribute(withNextPresentable: scene, withNextStepper: DefaultStepper())
    }
    return .contribute(withNextPresentable: scene, withNextStepper: reactor)
  }
}

#endif
