//
//  Connection.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import Synology
import Defaults

// MARK: - Connection

struct Connection: Codable, Defaults.Serializable {
  let uuid: UUID
  let creationDate: Date
  let name: String
  let url: URL
  let policy: Policy
  let ds: DiskStation

  init(name: String? = nil, diskStation: DiskStation, policy: Policy = .unknown) {
    self.uuid = UUID()
    self.creationDate = Date()
    self.name = name ?? diskStation.serverURL.host() ?? ""
    self.url = diskStation.serverURL
    self.policy = policy
    self.ds = diskStation
  }

  init(uuid: UUID, creationDate: Date, name: String, url: URL, policy: Policy, diskStation: DiskStation) {
    self.uuid = uuid
    self.creationDate = creationDate
    self.name = name
    self.url = url
    self.policy = policy
    self.ds = diskStation
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.uuid = try container.decode(UUID.self, forKey: .uuid)
    self.creationDate = try container.decode(Date.self, forKey: .creationDate)
    self.name = try container.decode(String.self, forKey: .name)
    self.url = try container.decode(URL.self, forKey: .url)
    self.policy = .persistent
    self.ds = DiskStation(serverURL: url)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(creationDate, forKey: .creationDate)
    try container.encode(name, forKey: .name)
    try container.encode(url, forKey: .url)
  }

  @inlinable func with(sessionID: String) -> Connection {
    Connection(
      uuid: uuid,
      creationDate: creationDate,
      name: name,
      url: url,
      policy: policy,
      diskStation: DiskStation(serverURL: url, sessionID: sessionID)
    )
  }
}

// MARK: - ConnectionInfo.CondingKeys

extension Connection {
  enum CodingKeys: String, CodingKey {
    case uuid
    case creationDate = "creation_date"
    case name
    case url
  }
}

// MARK: - Connection.Policy

extension Connection {
  enum Policy {
    case persistent
    case ephemeral
    case unknown
  }
}

// MARK: - Connection (Empty)

#if DEBUG

extension Connection {
  static func empty() -> Connection {
    Connection(
      uuid: UUID(),
      creationDate: Date(),
      name: "",
      url: URL(filePath: ""),
      policy: .unknown,
      diskStation: DiskStation(serverURL: URL(filePath: ""))
    )
  }
}

#endif
