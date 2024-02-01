//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Toto on 04.08.2023.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject?, file: StaticString = #filePath, line: UInt = #line ){
        //Check for memory leak
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
}
