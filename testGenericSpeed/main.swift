//
//  main.swift
//  testGenericSpeed
//
//  Created by Brice Rosenzweig on 18/12/2022.
//

import Foundation
import RZData

public struct DataFrameLocal<I : Comparable,T,F : Hashable> {
    //MARK: - Type definitions
    
    //MARK: - stored property
    public private(set) var indexes : [I]
    public private(set) var values : [F:[T]]
        
    public init(indexes : [I], fields : [F], rows : [[T]]){
        self.indexes = []
        self.values = [:]
        
        guard indexes.first != nil else {
            return
        }
        
        var lastindex = indexes.first!
        
        self.indexes.reserveCapacity(indexes.capacity)
        
        for field in fields {
            self.values[field] = []
            self.values[field]?.reserveCapacity(indexes.capacity)
        }
        
        for (index,row) in zip(indexes,rows) {
            if index < lastindex {
                self.indexes.removeAll(keepingCapacity: true)
                for field in fields {
                    self.values[field]?.removeAll(keepingCapacity: true)
                }
            }
            // edge case date is repeated
            if self.indexes.count == 0 || index != lastindex {
                // for some reason doing it manually here is much faster than calling function on dataframe?
                self.indexes.append(index)
                for (field,element) in zip(fields,row) {
                    //self.values[field, default: []].append(element)
                    self.values[field]?.append(element)
                }

                lastindex = index
            }
        }
    }
}

// generate

let nRows = 4000
let nCols = 80

var fields : [String] = (0..<nCols).map { "field\($0)" }
var indexes : [Int] = Array(0..<nRows)
var rows : [[Double]] = (0..<nRows).map { _ in
    (0..<nCols).map { _ in
        Double.random(in: 0.0...1.0)
    }
}


let start1 = Date()
let df = DataFrameLocal(indexes: indexes, fields: fields, rows: rows)
print( "Took \(Date().timeIntervalSince(start1))")

let start2 = Date()
let df2 = DataFrame(indexes: indexes, fields: fields, rows: rows)
print( "Took \(Date().timeIntervalSince(start2))")
