//
//  UIKit+Extension.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import UIKit

// MARK: - UISceneConfiguration (Creation)

extension UISceneConfiguration {
  convenience init(sessionRole: UISceneSession.Role, delegateClass: AnyClass) {
    self.init(name: nil, sessionRole: sessionRole)
    self.delegateClass = delegateClass
  }
}

// MARK: - UIView (SnapKit)

#if canImport(SnapKit)

import SnapKit

extension UIView {
  @inlinable func addLayoutGuide(_ layoutGuide: UILayoutGuide, makeConstraints: (ConstraintMaker) -> Void) {
    addLayoutGuide(layoutGuide)
    layoutGuide.snp.makeConstraints(makeConstraints)
  }

  @inlinable func addSubview(_ view: UIView, makeConstraints: (ConstraintMaker) -> Void) {
    addSubview(view)
    view.snp.makeConstraints(makeConstraints)
  }

  @inlinable func insertSubview(_ view: UIView, aboveSubview: UIView, makeConstraints: (ConstraintMaker) -> Void) {
    insertSubview(view, aboveSubview: aboveSubview)
    view.snp.makeConstraints(makeConstraints)
  }

  @inlinable func insertSubview(_ view: UIView, belowSubview: UIView, makeConstraints: (ConstraintMaker) -> Void) {
    insertSubview(view, belowSubview: belowSubview)
    view.snp.makeConstraints(makeConstraints)
  }
}

#endif
