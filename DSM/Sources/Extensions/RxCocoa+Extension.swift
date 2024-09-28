//
//  RxCocoa+Extension.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import RxSwift
import RxCocoa

// MARK: - Reactive (JustUI)

#if canImport(JustUI)

import JustUI

extension Reactive where Base: JKButton {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}

#endif
