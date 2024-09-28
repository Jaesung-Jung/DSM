//
//  HasDisposeBag.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

#if canImport(RxSwift)

import RxSwift

private var __disposeBagAssociatedKey: UInt8 = 0

protocol HasDisposeBag {
  var disposeBag: DisposeBag { get set }
}

extension HasDisposeBag where Self: AssociatedObjectSupporting {
  var disposeBag: DisposeBag {
    get {
      associatedObjectSync(
        forKey: &__disposeBagAssociatedKey,
        default: DisposeBag(),
        policy: .retainNonatomic
      )
    }
    set {
      setAssociatedObjectSync(newValue, forKey: &__disposeBagAssociatedKey, policy: .retainNonatomic)
    }
  }
}

#endif
