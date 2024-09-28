//
//  IntroViewTests.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import UIKit
import Testing
@testable import DSM

@MainActor
@Suite struct IntroViewTests {
  @Test func connectActionTest() {
    let reactor = IntroReactor()
    reactor.isStubEnabled = true

    let viewController = IntroViewController(reactor: reactor)
    viewController.connectButton.sendActions(for: .touchUpInside)

    #expect(reactor.stub.actions.last == .connection)
  }
}
