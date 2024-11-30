//
//  DSMError.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import Foundation

enum DSMError: LocalizedError {
  case unableToConnectServer(String)
  case cannotFindQuickConnectID(String)

  var errorDescription: String? {
    String(localized: localizedErrorDescription)
  }

  var localizedErrorDescription: String.LocalizationValue {
    switch self {
    case .unableToConnectServer(let string):
      return "Unable to connect to **\(string)**"
    case .cannotFindQuickConnectID(let string):
      return "The QuickConnectID **\(string)** cannot be found."
    }
  }
}
