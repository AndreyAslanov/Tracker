//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Андрей Асланов on 07.12.23.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewController() {
         let vc = TrackerViewController()
        _ = vc.view
         assertSnapshot(matching: vc, as: .image)
     }
}
