//
//  AuthKeychain.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import KeychainAccess
import JustFoundation

class AuthKeychain {
  private let _keychain: Keychain?
  private let _cache = Cache<UUID, Item>(name: "auth_info_cache")

  init() {
    if let appIdentifierPrefix = Bundle.main.infoDictionary.flatMap({ $0["AppIdentifierPrefix"] as? String }), let bundleIdentifier = Bundle.main.bundleIdentifier {
      _keychain = Keychain(service: bundleIdentifier, accessGroup: "\(appIdentifierPrefix)\(bundleIdentifier)")
    } else {
      _keychain = nil
    }
  }

  func item(for uuid: UUID) -> Item? {
    if let item = _cache.object(forKey: uuid) {
      return item
    }
    do {
      guard let data = try _keychain?.getData("dsm-\(uuid.uuidString)") else {
        return nil
      }
      let item = try JSONDecoder().decode(Item.self, from: data)
      _cache.setObject(item, forKey: uuid)
      return item
    } catch {
      Log.error(error)
      return nil
    }
  }

  @inlinable func sessionID(for uuid: UUID) -> String? {
    item(for: uuid)?.sessionID
  }

  @inlinable func deviceID(for uuid: UUID) -> String? {
    item(for: uuid)?.deviceID
  }

  func setItem(_ item: Item, for uuid: UUID) {
    do {
      let data = try JSONEncoder().encode(item)
      try _keychain?.set(data, key: "dsm-\(uuid.uuidString)")
      _cache.removeObject(forKey: uuid)
    } catch {
      Log.error(error)
    }
  }

  func set(sessionID: String, deviceID: String, for uuid: UUID) {
    setItem(Item(sessionID: sessionID, deviceID: deviceID), for: uuid)
  }

  func setSessionID(_ sessionID: String, for uuid: UUID) {
    let newItem: Item
    if let item = item(for: uuid) {
      newItem = Item(sessionID: sessionID, deviceID: item.deviceID)
    } else {
      newItem = Item(sessionID: sessionID, deviceID: "")
    }
    setItem(newItem, for: uuid)
  }

  func setDeviceID(_ deviceID: String, for uuid: UUID) {
    let newItem: Item
    if let item = item(for: uuid) {
      newItem = Item(sessionID: item.sessionID, deviceID: deviceID)
    } else {
      newItem = Item(sessionID: "", deviceID: deviceID)
    }
    setItem(newItem, for: uuid)
  }

  func removeItem(for uuid: UUID) {
    do {
      try _keychain?.remove("dsm-\(uuid.uuidString)")
    } catch {
      Log.error(error)
    }
  }

  func removeUnknownKeys(validItems: [UUID]) {
    guard let keychain = _keychain else {
      return
    }
    let validKeys = Set(validItems.map { "dsm-\($0.uuidString)" })
    for key in keychain.allKeys() where !validKeys.contains(key) {
      Log.debug("remove unknown key: \(key)")
      try? keychain.remove(key)
    }
  }
}

// MARK: - AuthKeychain.Item

extension AuthKeychain {
  struct Item: Codable {
    let sessionID: String
    let deviceID: String
  }
}
