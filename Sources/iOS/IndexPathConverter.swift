//
//  IndexPathConverter.swift
//  DeepDiff
//
//  Created by Khoa Pham.
//  Copyright © 2018 Khoa Pham. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation

public struct ChangeWithIndexPath {
  
  public let inserts: [IndexPath]
  public let deletes: [IndexPath]
  public let replaces: [IndexPath]
  public let moves: [(from: IndexPath, to: IndexPath)]

  public init(
    inserts: [IndexPath],
    deletes: [IndexPath],
    replaces:[IndexPath],
    moves: [(from: IndexPath, to: IndexPath)]) {

    self.inserts = inserts
    self.deletes = deletes
    self.replaces = replaces
    self.moves = moves
  }
}

public class IndexPathConverter {
  
  public init() {}
  
  public static func convert<T>(changes: [Change<T>]) -> ChangeWithIndexPath {
    let inserts = changes.compactMap({ $0.insert }).map({ $0.index.toIndexPath() })
    let deletes = changes.compactMap({ $0.delete }).map({ $0.index.toIndexPath() })
    let replaces = changes.compactMap({ $0.replace }).map({ $0.index.toIndexPath() })
    let moves = changes.compactMap({ $0.move }).map({
      (
        from: $0.fromIndex.toIndexPath(),
        to: $0.toIndex.toIndexPath()
      )
    })
    
    return ChangeWithIndexPath(
      inserts: inserts,
      deletes: deletes,
      replaces: replaces,
      moves: moves
    )
  }
}

extension Int {
  
  fileprivate func toIndexPath() -> IndexPath {
    return IndexPath(item: 0, section: self)
  }
}
#endif
