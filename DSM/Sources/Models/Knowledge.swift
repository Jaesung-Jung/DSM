//
//  Knowledge.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation

// MARK: - Knowledge

struct Knowledge {
  static let baseURL = URL(string: "https://kb.synology.com")!

  let url: URL

  init(path: String, preferredLanguages: [String] = Locale.preferredLanguages) {
    let languages = preferredLanguages
      .compactMap { Language(rawValue: $0.split(separator: "_").first.map { String($0) } ?? $0) }
    let preferredLanguage = languages.first ?? .english
    self.url = Knowledge.baseURL
      .appending(path: preferredLanguage.localeIdentifier)
      .appending(path: "DSM")
      .appending(path: path)
  }
}

// MARK: - Knowledge (Creation)

extension Knowledge {
  static var quickConnect: Knowledge {
    Knowledge(path: "help/DSM/AdminCenter/connection_quickconnect")
  }

  static var quickConnectTroubleshooting: Knowledge {
    Knowledge(path: "tutorial/Why_can_t_I_connect_to_my_Synology_NAS_over_the_Internet_via_QuickConnect")
  }

  static var forgotPassword: Knowledge {
    Knowledge(path: "tutorial/How_do_I_log_in_if_I_forgot_the_admin_password")
  }

  static var twoFactorAuthentication: Knowledge {
    Knowledge(path: "help/DSM/SecureSignIn/2factor_authentication")
  }
}

// MARK: - Knowledge.Language

extension Knowledge {
  enum Language: String {
    case english      = "en"
    case spanish      = "es"
    case chinese      = "zh"
    case japanese     = "ja"
    case korean       = "ko"
    case danish       = "da"
    case hungarian    = "hu"
    case vietnamese   = "vi"
    case thai         = "th"
    case swedish      = "sv"
    case turkish      = "tr"
    case czech        = "cs"
    case german       = "de"
    case french       = "fr"
    case italian      = "it"
    case dutch        = "nl"
    case polish       = "pl"
    case russian      = "ru"

    var localeIdentifier: String {
      switch self {
      case .english:
        return "\(rawValue)-global"
      case .spanish:
        return "\(rawValue)-es"
      case .chinese:
        return "\(rawValue)-tw"
      case .japanese:
        return "\(rawValue)-jp"
      case .korean:
        return "\(rawValue)-kr"
      case .danish:
        return "\(rawValue)-dk"
      case .hungarian:
        return "\(rawValue)-hu"
      case .vietnamese:
        return "\(rawValue)-vn"
      case .thai:
        return "\(rawValue)-th"
      case .swedish:
        return "\(rawValue)-se"
      case .turkish:
        return "\(rawValue)-tr"
      case .czech:
        return "\(rawValue)-cz"
      case .german:
        return "\(rawValue)-de"
      case .french:
        return "\(rawValue)-fr"
      case .italian:
        return "\(rawValue)-it"
      case .dutch:
        return "\(rawValue)-nl"
      case .polish:
        return "\(rawValue)-pl"
      case .russian:
        return "\(rawValue)-ru"
      }
    }
  }
}
