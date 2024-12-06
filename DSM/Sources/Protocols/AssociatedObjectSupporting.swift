//
//  AssociatedObjectSupporting.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation

// MARK: - AssociatedObjectSupporting

protocol AssociatedObjectSupporting: AnyObject {
}

// MARK: - AssociatedObjectSupporting (Extension Methods)

extension AssociatedObjectSupporting {
  func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(self, key) as? T
  }

  func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T, policy: AssociationPolicy) -> T {
    if let object: T = associatedObject(forKey: key) {
      return object
    }
    let object = `default`()
    setAssociatedObject(object, forKey: key, policy: policy)
    return object
  }

  func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer, policy: AssociationPolicy) {
    objc_setAssociatedObject(self, key, object, policy.objcAssociationPolicy)
  }

  func associatedObjectSync<T>(forKey key: UnsafeRawPointer) -> T? {
    objc_sync_enter(self)
    let object: T? = associatedObject(forKey: key)
    objc_sync_exit(self)
    return object
  }

  func associatedObjectSync<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T, policy: AssociationPolicy) -> T {
    objc_sync_enter(self)
    let object: T = associatedObject(forKey: key, default: `default`(), policy: policy)
    objc_sync_exit(self)
    return object1
  }

  func setAssociatedObjectSync<T>(_ object: T?, forKey key: UnsafeRawPointer, policy: AssociationPolicy) {
    objc_sync_enter(self)
    objc_setAssociatedObject(self, key, object, policy.objcAssociationPolicy)
    objc_sync_exit(self)
  }
}

// MARK: - AssociationPolicy

enum AssociationPolicy: UInt {
  case assign = 0
  case copy = 771
  case copyNonatomic = 3
  case retain = 769
  case retainNonatomic = 1

  fileprivate var objcAssociationPolicy: objc_AssociationPolicy {
    objc_AssociationPolicy(rawValue: rawValue)!
  }
}

// MARK: - NSObject (AssociatedObjectSupporting)

extension NSObject: AssociatedObjectSupporting {
}
