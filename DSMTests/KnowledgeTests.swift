//
//  KnowledgeTests.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import Testing
@testable import DSM

@Suite struct KnowledgeTests {
  @Test func testKnowledgeURLGenerationEnglish() throws {
    let knowledge = Knowledge(path: "test")
    let expectedURL = try url(path: "en-global/DSM/test")
    #expect(knowledge.url == expectedURL)
  }

  @Test func testKnowledgeURLGenerationKorean() throws {
    let knowledge = Knowledge(path: "test", preferredLanguages: ["ko_KR"])
    let expectedURL = try url(path: "\(Knowledge.Language.korean.localeIdentifier)/DSM/test")
    #expect(knowledge.url == expectedURL)
  }

  @Test func testKnowledgeURLGenerationJapanese() throws {
    let knowledge = Knowledge(path: "test", preferredLanguages: ["ja_JP"])
    let expectedURL = try url(path: "\(Knowledge.Language.japanese.localeIdentifier)/DSM/test")
    #expect(knowledge.url == expectedURL)
  }

  func url(path: String) throws -> URL {
    try #require(URL(string: "\(Knowledge.baseURL.absoluteString)/\(path)"))
  }
}
