//
//  SceneViewController.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import SwiftUI
import ReactorKit
import SnapKit
import JustUI

// MARK: - SceneViewController

class SceneViewController<R: Reactor>: UIViewController, ReactorKit.View, HasDisposeBag {
  typealias View = SwiftUI.View
  typealias Reactor = R
  typealias Action = R.Action
  typealias State = R.State

  private var _sceneLayoutGuideConstraint: Constraint?

  let sceneLayoutGuide = UILayoutGuide().then {
    $0.identifier = "SceneLayoutGuide"
  }

  var sceneLayoutEdgeInsets: SceneLayoutEdgeInsets { .zero }
  var sceneLayoutMaxSize: SceneLayoutMaxSize { .automatic }

  var clearsSelectionOnViewWillAppear: Bool { false }

  init(reactor: R? = nil) {
    super.init(nibName: nil, bundle: nil)
    if let reactor {
      self.reactor = reactor
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard clearsSelectionOnViewWillAppear else {
      return
    }
    _clearSelection(animated: animated)
  }

  func bind(reactor: R) {
    fatalError("bind(reactor:) has not been implemented")
  }

  func configureUI() {
    view.backgroundColor = .background
    view.addLayoutGuide(sceneLayoutGuide) {
      _sceneLayoutGuideConstraint = $0.directionalEdges.equalTo(view.safeAreaLayoutGuide).constraint
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let rect = view.frame.inset(by: view.safeAreaInsets)
    var insets: NSDirectionalEdgeInsets = .zero
    switch sceneLayoutEdgeInsets.top {
    case .absolute(let value):
      insets.top = value
    case .fractional(let value):
      insets.top = max(0, value) * rect.height
    }
    switch sceneLayoutEdgeInsets.bottom {
    case .absolute(let value):
      insets.bottom = value
    case .fractional(let value):
      insets.bottom = max(0, value) * rect.height
    }
    switch sceneLayoutEdgeInsets.leading {
    case .absolute(let value):
      insets.leading = value
    case .fractional(let value):
      insets.leading = max(0, value) * rect.width
    }
    switch sceneLayoutEdgeInsets.trailing {
    case .absolute(let value):
      insets.trailing = value
    case .fractional(let value):
      insets.trailing = max(0, value) * rect.width
    }

    if let maxWidth = sceneLayoutMaxSize.width, (rect.width - insets.horizontal) > maxWidth {
      let inset = (rect.width - maxWidth) * 0.5
      insets.leading = inset
      insets.trailing = inset
    }
    if let maxHeight = sceneLayoutMaxSize.height, (rect.height - insets.vertical) > maxHeight {
      let inset = (rect.width - maxHeight) * 0.5
      insets.top = inset
      insets.bottom = inset
    }

    _sceneLayoutGuideConstraint?.update(inset: insets)
  }
}

// MARK: - SceneViewController (Private)

extension SceneViewController {
  private func _clearSelection(animated: Bool) {
    guard let transitionCoordinator else {
      return
    }
    let selectItems: (() -> Void)?
    let deselectItems: (() -> Void)?
    if let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView, let indexPaths = collectionView.indexPathsForSelectedItems {
      selectItems = {
        for indexPath in indexPaths {
          collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
      }
      deselectItems = {
        for indexPath in indexPaths {
          collectionView.deselectItem(at: indexPath, animated: true)
        }
      }
    } else if let tableView = view.subviews.first(where: { $0 is UITableView }) as? UITableView, let indexPaths = tableView.indexPathsForSelectedRows {
      selectItems = {
        for indexPath in indexPaths {
          tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        }
      }
      deselectItems = {
        for indexPath in indexPaths {
          tableView.deselectRow(at: indexPath, animated: animated)
        }
      }
    } else {
      selectItems = nil
      deselectItems = nil
    }

    guard let selectItems, let deselectItems else {
      return
    }
    transitionCoordinator.animate { _ in
      deselectItems()
    } completion: { context in
      if context.isCancelled {
        selectItems()
      }
    }
  }
}
// MARK: - SceneViewController.LayoutMargins

extension SceneViewController {
  struct SceneLayoutEdgeInsets: Equatable {
    let top: LayoutUnit
    let leading: LayoutUnit
    let bottom: LayoutUnit
    let trailing: LayoutUnit

    init(top: LayoutUnit = 0, leading: LayoutUnit = 0, bottom: LayoutUnit = 0, trailing: LayoutUnit = 0) {
      self.top = top
      self.leading = leading
      self.bottom = bottom
      self.trailing = trailing
    }

    static var zero: SceneLayoutEdgeInsets { SceneLayoutEdgeInsets() }
  }
}

// MARK: - SceneViewController.SceneLayoutMaxSize

extension SceneViewController {
  struct SceneLayoutMaxSize: Equatable {
    let width: CGFloat?
    let height: CGFloat?

    init(width: CGFloat? = nil, height: CGFloat? = nil) {
      self.width = width
      self.height = height
    }

    static var automatic: SceneLayoutMaxSize { SceneLayoutMaxSize() }
  }
}

// MARK: - SceneViewController.LayoutDimension

extension SceneViewController {
  enum LayoutUnit: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Equatable {
    case absolute(CGFloat)
    case fractional(CGFloat)

    init(integerLiteral value: IntegerLiteralType) {
      self = .absolute(CGFloat(value))
    }

    init(floatLiteral value: FloatLiteralType) {
      self = .absolute(CGFloat(value))
    }

    static func == (lhs: LayoutUnit, rhs: LayoutUnit) -> Bool {
      switch (lhs, rhs) {
      case (.absolute(let value1), .absolute(let value2)):
        return value1 == value2
      case (.fractional(let value1), .fractional(let value2)):
        return value1 == value2
      default:
        return false
      }
    }
  }
}

// MARK: - SceneViewController<NoReactor> (Creation)

extension SceneViewController where R == NoReactor {
  convenience init() {
    self.init(reactor: NoReactor())
  }
}

// MARK: - NoReactor

final class NoReactor: Reactor {
  typealias Action = NoAction
  typealias Mutation = NoMutation

  struct State {
  }

  let initialState = State()

  func mutate(action: Action) -> Observable<Mutation> {
  }

  func reduce(state: State, mutation: Mutation) -> State {
  }
}
