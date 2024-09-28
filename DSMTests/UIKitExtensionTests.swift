//
//  UIKitExtensionTests.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import UIKit
import Testing
@testable import DSM

@MainActor
@Suite struct UIKitExtensionsTests {
  // MARK: - UISceneConfiguration Tests

  @Test func testUISceneConfigurationIniti() {
    class MockSceneDelegate: NSObject, UIWindowSceneDelegate {
    }
    let mockDelegateClass = MockSceneDelegate.self
    let sceneConfig = UISceneConfiguration(sessionRole: .windowApplication, delegateClass: MockSceneDelegate.self)
    #expect(sceneConfig.role == .windowApplication)
    #expect(sceneConfig.delegateClass == mockDelegateClass)
  }
}
