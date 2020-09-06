//
//  File.swift
//  
//
//  Created by James Irwin on 9/6/20.
//

import Foundation

///The Dancing links Grid/Matrix terminology comes from Knuth's paper on Algorithm X
public struct XGrid {
    //MARK: - Public Properties
    public var columns: DLXColumns
    public var rows: [Set<Int>]
    public var activeRows: Set<Int>
    public var solution: Set<Int> = []
    
    //MARK: - Initializer
    public init(_ numberOfRows: Int, _ numberOfColumns: Int, _ rowConstructor: (Int)->Set<Int>) {
        activeRows = []
        rows = []
        columns = DLXColumns(numberOfColumns)
        for i in 0..<numberOfRows {
            let cols = rowConstructor(i)
            rows.append(cols)
            activeRows.insert(i)
            for c in cols {
                columns.insert(i, at: c)
            }
        }
    }
    
    //MARK: - Cover & Uncover
    
    ///Cover a row Knuth does it by columns however this seems a bit more succinct if you plan to backtrace you need to keep the result
    @discardableResult
    public mutating func cover(_ row: Int) -> Set<Int> {
        solution.insert(row)
        var intersectingRows = Set<Int>()
        for c in rows[row] {
            guard let column = columns[c] else {
                print("In standard dlx implementation this shouldnt happen check your methods, possible you have used an instance that has already been solved destructively; results might not be accurate")
                continue
            }
            columns[c] = nil //remove this column from the list entirely
            for r in column {
                activeRows.remove(r)
                intersectingRows.insert(r)
                for k in rows[r] {
                    columns.remove(r at: k)
                }
            }
        }
        return associatedRows
    }
    
    ///Uncover method
    public mutating func uncover(_ row: Int, _ intersectingRows: Set<Int>) {
        solution.remove(row)
        for r in intersectingRows {
            activeRows.insert(r)
            for c in rows[r] {
                columns.insert(r, at: c)
            }
        }
    }
    
    
}
