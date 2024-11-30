//
//  ConnectionManager.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import Foundation
import KeychainAccess
import Synology
import Defaults

// MARK: - ConnectionManager

final class ConnectionManager {
  private let _defaults = UserDefaults(suiteName: "dsm.connections")
  private let _keychain: AuthKeychain

  var recentConnection: Connection? {
    get {
      guard let defaults = _defaults else {
        return nil
      }
      let uuid = defaults[.latestConnectionUUID]
      guard let connection = defaults[.connections].first(where: { $0.uuid == uuid }) else {
        return nil
      }
      guard let keychainItem = _keychain.item(for: connection.uuid) else {
        return connection
      }
      return connection.with(sessionID: keychainItem.sessionID)
    }
    set {
      _defaults?[.latestConnectionUUID] = newValue?.uuid
    }
  }

  var connections: [Connection] {
    let connections = _defaults?[.connections] ?? []
    return connections.map {
      guard let keychainItem = _keychain.item(for: $0.uuid) else {
        return $0
      }
      return $0.with(sessionID: keychainItem.sessionID)
    }
  }

  init(keychain: AuthKeychain) {
    self._keychain = keychain
    keychain.removeUnknownKeys(validItems: connections.map(\.uuid))
  }

  func appendConnection(_ newConnection: Connection) {
    _defaults?[.connections].append(newConnection)
  }

  func updateConnection(_ connection: Connection) {
  }

  func removeConnection(_ connection: Connection) {
    if let defaults = _defaults, let index = defaults[.connections].firstIndex(where: { $0.uuid == connection.uuid }) {
      defaults[.connections].remove(at: index)
    }
    _keychain.removeItem(for: connection.uuid)
  }
}

// MARK: - Defaults.Keys (Connection)

extension Defaults.Keys {
  fileprivate static let latestConnectionUUID = Key<UUID?>("latest_connection", default: nil)
  fileprivate static let connections = Key<[Connection]>("connections", default: [])
}
