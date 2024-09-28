//
//  AppPreferences.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import Defaults

// MARK: - AppPreferences

final class AppPreferences {
  @Default(.preference.fileStation)
  var fileStation

  @Default(.preference.filePicker)
  var filePicker

  func update(_ updateHandler: @MainActor (AppPreferences) -> Void) async {
    await MainActor.run {
      updateHandler(self)
    }
  }
}

// MARK: - AppPreferences.FileStation

extension AppPreferences {
  struct FileStation: Codable, Equatable, _DefaultsSerializable {
    var layout: Int = 0
    var sortBy: String = "name"
    var sortByAscending: Bool = true
  }
}

extension AppPreferences {
  struct FilePicker: Codable, Equatable, _DefaultsSerializable {
    var sortBy: String = "name"
    var sortByAscending: Bool = true
  }
}

// MARK: - AppPreferences Keys

extension Defaults.Keys {
  static let preference = AppPreferences.Key.self
}

extension AppPreferences {
  enum Key {
    static let fileStation = Defaults.Key<FileStation>("file_station", default: FileStation())
    static let filePicker = Defaults.Key<FileStation>("file_picker", default: FileStation())
  }
}

// MARK: - AppPreferences (Reactive)

#if canImport(RxSwift)

import RxSwift

extension AppPreferences: ReactiveCompatible {
}

extension Reactive where Base: AppPreferences {
  func observe<Value>(_ key: Defaults.Key<Value>) -> Observable<Value> {
    #if DEBUG
    if ProcessInfo.processInfo.isPreview {
      return .empty()
    }
    return Defaults.updates(key).asObservable()
    #else
    return Defaults.updates(key).asObservable()
    #endif
  }
}

#endif
