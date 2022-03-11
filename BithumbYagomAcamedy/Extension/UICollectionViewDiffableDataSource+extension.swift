//
//  CollectionViewDiffableDataSource+extension.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/03/11.
//

import UIKit

extension UICollectionViewDiffableDataSource {
    func applySnapshot(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if #available(iOS 15.0, *) {
            self.apply(snapshot, animatingDifferences: animated, completion: completion)
        } else {
            if animated {
                self.apply(snapshot, animatingDifferences: true, completion: completion)
            } else {
                UIView.performWithoutAnimation {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                }
            }
        }
    }
}
