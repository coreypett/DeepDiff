//
//  UICollectionView+Extensions.swift
//  DeepDiff
//
//  Created by Khoa Pham.
//  Copyright © 2018 Khoa Pham. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UICollectionView {
  
  /// Animate reload in a batch update
  ///
  /// - Parameters:
  ///   - changes: The changes from diff
  ///   - section: The section that all calculated IndexPath belong
  ///   - updateData: Update your data source model
  ///   - completion: Called when operation completes
  func reloadSections<T: DiffAware>(
    changes: [Change<T>],
    updateData: () -> Void,
    completion: ((Bool) -> Void)? = nil) {
    
    let changesWithIndexPath = IndexPathConverter.convertSection(changes: changes)
    
    performBatchUpdates({
      updateData()
      insideUpdateSections(changesWithIndexPath: changesWithIndexPath)
    }, completion: { finished in
      completion?(finished)
    })

    // reloadRows needs to be called outside the batch
    outsideUpdateSections(changesWithIndexPath: changesWithIndexPath)
  }
  
  // MARK: - Helper
  
  private func insideUpdateSections(changesWithIndexPath: ChangeWithIndexPath) {
    changesWithIndexPath.deletes.executeIfPresent {
        let sections = $0.compactMap { $0.section }
      deleteSections(IndexSet(sections))
    }
    
    changesWithIndexPath.inserts.executeIfPresent {
        let sections = $0.compactMap { $0.section }
      insertSections(IndexSet(sections))
    }
    
    changesWithIndexPath.moves.executeIfPresent {
      $0.forEach { move in
        moveSection(move.from.section, toSection: move.to.section)
      }
    }
  }

  private func outsideUpdateSections(changesWithIndexPath: ChangeWithIndexPath) {
    changesWithIndexPath.replaces.executeIfPresent {
        let sections = $0.compactMap { $0.section }
        self.reloadSections(IndexSet(sections))
    }
  }
}

public extension UICollectionView {

  /// Animate reload in a batch update
  ///
  /// - Parameters:
  ///   - changes: The changes from diff
  ///   - section: The section that all calculated IndexPath belong
  ///   - updateData: Update your data source model
  ///   - completion: Called when operation completes
  func reloadItems<T: DiffAware>(
    changes: [Change<T>],
    section: Int = 0,
    updateData: () -> Void,
    completion: ((Bool) -> Void)? = nil) {

    let changesWithIndexPath = IndexPathConverter.convert(changes: changes, section: section)

    performBatchUpdates({
      updateData()
      insideUpdate(changesWithIndexPath: changesWithIndexPath)
    }, completion: { finished in
      completion?(finished)
    })

    // reloadRows needs to be called outside the batch
    outsideUpdate(changesWithIndexPath: changesWithIndexPath)
  }

  // MARK: - Helper

  private func insideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
    changesWithIndexPath.deletes.executeIfPresent {
      deleteItems(at: $0)
    }

    changesWithIndexPath.inserts.executeIfPresent {
      insertItems(at: $0)
    }

    changesWithIndexPath.moves.executeIfPresent {
      $0.forEach { move in
        moveItem(at: move.from, to: move.to)
      }
    }
  }

  private func outsideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
    changesWithIndexPath.replaces.executeIfPresent {
      self.reloadItems(at: $0)
    }
  }
}
#endif
