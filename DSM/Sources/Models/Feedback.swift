//
//  Feedback.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import UIKit

enum Feedback {
  @inlinable static func selection() {
    UISelectionFeedbackGenerator().selectionChanged()
  }

  @inlinable static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat? = nil) {
    if let intensity {
      UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
    } else {
      UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
  }

  @inlinable static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(type)
  }
}
