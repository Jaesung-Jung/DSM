//
//  RxSwift+Extension.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

#if canImport(RxSwift) && canImport(RxCocoa)

import UIKit
import RxSwift
import RxCocoa

// MARK: - ObservableType<Void>

extension ObservableType where Element == Void {
  func withUnretained<Object: AnyObject>(_ obj: Object) -> Observable<Object> {
    withUnretained(obj) { obj, _ in obj }
  }
}

// MARK: - ObservableType

extension ObservableType {
  func map<Result>(_ transform: @escaping () throws -> Result) -> Observable<Result> {
    map { _ in try transform() }
  }

  func map() -> Observable<Void> { map { _ in } }

  func merge<O: ObservableType>(_ observable: O) -> Observable<Element> where O.Element == Element {
    Observable.merge(self.asObservable(), observable.asObservable())
  }

  func bind<Object: AnyObject>(with object: Object, onNext: @escaping (Object) -> Void) -> Disposable {
    bind(with: object) { object, _ in
      onNext(object)
    }
  }

  func bind(onNext: @escaping () -> Void) -> Disposable {
    subscribe(
      onNext: { _ in onNext() },
      onError: {
        #if DEBUG
        fatalError("Binding error: \($0)")
        #endif
      }
    )
  }
}

// MARK: - PrimitiveSequenceType

extension PrimitiveSequenceType where Trait == SingleTrait {
  func map() -> Single<Void> { map { _ in } }
}

// MARK: - PrimitiveSequence

extension PrimitiveSequence where Trait == MaybeTrait {
  func map() -> Maybe<Void> { map { _ in } }
}

// MARK: - Infallible

extension Infallible {
  func map() -> Infallible<Void> { map { _ in } }
}

// MARK: - PublishRelay<Void>

extension PublishRelay where Element == Void {
  func accept() {
    self.accept(())
  }
}

// MARK: - UIViewController (Reactive)

extension Reactive where Base: UIViewController {
  var viewDidLoad: ControlEvent<Void> {
    let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewWillAppear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidAppear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillDisappear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidDisappear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillLayoutSubviews: ControlEvent<Void> {
    let source = self.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewDidLayoutSubviews: ControlEvent<Void> {
    let source = self.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var willMoveToParentViewController: ControlEvent<UIViewController?> {
    let source = self.methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
    return ControlEvent(events: source)
  }

  var didMoveToParentViewController: ControlEvent<UIViewController?> {
    let source = self.methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
    return ControlEvent(events: source)
  }

  var didReceiveMemoryWarning: ControlEvent<Void> {
    let source = self.methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
    return ControlEvent(events: source)
  }

  var isVisible: Observable<Bool> {
    let viewDidAppearObservable = self.base.rx.viewDidAppear.map { _ in true }
    let viewWillDisappearObservable = self.base.rx.viewWillDisappear.map { _ in false }
    return Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable)
  }

  var isDismissing: ControlEvent<Bool> {
    let source = self.sentMessage(#selector(Base.dismiss)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }
}

// MARK: - UITextField (Reactive)

extension Reactive where Base: UITextField {
  var keyboardReturn: ControlEvent<Void> {
    return controlEvent(.editingDidEndOnExit)
  }
}

// MARK: - UIScrollView (Reactive)

extension Reactive where Base: UIScrollView {
  func reachedBottom(offset: CGFloat = 0.0) -> ControlEvent<Void> {
    let source = contentOffset
      .map { contentOffset in
        let visibleHeight = self.base.frame.height - self.base.contentInset.top - self.base.contentInset.bottom
        let y = contentOffset.y + self.base.contentInset.top
        let threshold = max(offset, self.base.contentSize.height - visibleHeight)
        return y >= threshold
      }
      .distinctUntilChanged()
      .filter { $0 }
      .map { _ in }
    return ControlEvent(events: source)
  }
}

// MARK: - UICollectionView (Reactive)

extension Reactive where Base: UICollectionView {
  var indexPathsForSelectedItems: Observable<[IndexPath]> {
    let selectItem = methodInvoked(#selector(base.selectItem(at:animated:scrollPosition:)))
    let deselectItem = methodInvoked(#selector(base.deselectItem(at:animated:)))
    return Observable.from([
      itemSelected.map { _ in },
      itemDeselected.map { _ in },
      selectItem.map { _ in },
      deselectItem.map { _ in }
    ])
    .merge()
    .compactMap { [weak base] in
      base.map { $0.indexPathsForSelectedItems ?? [] }
    }
    .startWith(base.indexPathsForSelectedItems ?? [])
  }
}

#endif
