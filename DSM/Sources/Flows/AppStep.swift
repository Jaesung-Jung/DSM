//
//  AppStep.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import Foundation
import RxFlow
import Synology

enum AppStep: Step {
  // Main
  case main

  // Tab
  case home
  case fileStation
  case downloadStation
  case settings

  // Connect
  case connection
  case connectionCompleted(connection: Connection)
  case connectionCanceled

  // Login
  case login(connection: Connection, isReauthentication: Bool)
  case loginCompleted(connection: Connection, authorization: Auth.Authorization, savesSessionID: Bool, savesDeviceID: Bool)
  case twoFactorAuthentication(connection: Connection, account: String, password: String, savesSessionID: Bool)
  case twoFactorAuthenticationCompleted(connection: Connection, authorization: Auth.Authorization, savesSessionID: Bool)
  case loginCanceled

  // FileStation
  case files(path: String)
  case open(file: FileStation.File)
  case openQuickLook(fileURL: URL, deleteLastViewController: Bool)

  // FilePicker
  case filePicker(path: String? = nil, shouldSelectFile: Bool = true, doneButtonTitle: String? = nil, completionHandler: (FileStation.File?) -> Void)
  case filePickerFiles(path: String?)
  case filePickerSelected(file: FileStation.File)
  case filePickerCanceled

  // Common
  case knowledgeCenter(Knowledge)
}
