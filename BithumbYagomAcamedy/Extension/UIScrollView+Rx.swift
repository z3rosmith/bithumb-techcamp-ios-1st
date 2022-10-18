//
//  UIScrollView+Rx.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/24.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    var didEndScroll: ControlEvent<Void> {
        let source = Observable.merge(
            base.rx.didEndDragging.filter { $0 == false }.map { _ in },
            base.rx.didEndDecelerating.map { _ in }
        )
        return ControlEvent(events: source)
    }
}
