//
//  ConnectionTests.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import Testing
@testable import DSM
@testable import Synology

@Suite struct ConnectionTests {
  @Test func testConnectionInitialization() {
    let url = URL(string: "https://synology.local")!
    let diskStation = DiskStation(serverURL: url)
    let connection = Connection(name: "Home Server", diskStation: diskStation, policy: .persistent)

    #expect(connection.name == "Home Server")
    #expect(connection.url == url)
    #expect(connection.policy == .persistent)
    #expect(connection.ds === diskStation)
  }

  @Test func testConnectionWithDefaultName() {
    let url = URL(string: "https://synology.local")!
    let diskStation = DiskStation(serverURL: url)
    let connection = Connection(diskStation: diskStation)

    #expect(connection.name == "synology.local") // Default name from host
    #expect(connection.url == url)
  }

  @Test func testConnectionWithSessionID() async {
    let url = URL(string: "https://synology.local")!
    let diskStation = DiskStation(serverURL: url)
    let connection = Connection(name: "Home Server", diskStation: diskStation, policy: .persistent)

    let updatedConnection = connection.with(sessionID: "new-session-id")
    #expect(await updatedConnection.ds.authStore.sessionID == "new-session-id")
  }

  @Test func testEncodingAndDecoding() throws {
    let url = URL(string: "https://synology.local")!
    let diskStation = DiskStation(serverURL: url)
    let connection = Connection(name: "Home Server", diskStation: diskStation, policy: .persistent)

    // Encoding
    let encoder = JSONEncoder()
    let encodedData = try encoder.encode(connection)

    // Decoding
    let decoder = JSONDecoder()
    let decodedConnection = try decoder.decode(Connection.self, from: encodedData)

    #expect(decodedConnection.uuid == connection.uuid)
    #expect(decodedConnection.creationDate == connection.creationDate)
    #expect(decodedConnection.name == connection.name)
    #expect(decodedConnection.url == connection.url)
  }
}
