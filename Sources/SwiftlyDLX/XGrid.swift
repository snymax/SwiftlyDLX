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
    ///Initialize with a "Callback" which constructs a set of columns that intersect with each row
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
    
    ///Initialize with 2d array This will be faster for obvious reasons
    public init(_ numberOfColumns: Int, _ grid: [Set<Int>]) {
        activeRows = []
        rows = grid
        columns = DLXColumns(numberOfColumns)
        for i in 0..<grid.count {
            activeRows.insert(i)
            for c in grid[i] {
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
                    columns.remove(r, at: k)
                }
            }
        }
        return intersectingRows
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
    
    
    ///Cover multiple rows
    @discardableResult
    public mutating func cover(_ rows: Set<Int>) -> [(Int,Set<Int>)] {
        var d = [(Int,Set<Int>)]() //cant use dictionary here order actually matters
        for r in rows {
            d.insert((r, cover(r)), at: 0) //Last off first on
        }
        return d
    }
    
    ///Uncover Mutliple rows
    public mutating func uncover(_ rows: [(Int, Set<Int>)]) {
        for n in rows {
            uncover(n.0, n.1)
        }
    }
    //MARK: - Solvers
    
    ///Fill a puzzle with a set number of random values then solve for the rest
    public mutating func fill(_ count: Int) -> Set<Int>? {
        guard count > 0 else { return solve() }
        guard let column = columns.random else { return solution }
        let nc = count-1
        for row in column {
            let cx = cover(row)
            let s = fill(nc)
            uncover(row, cx)
            guard s == nil else { return s }
        }
        return nil
    }
    
    ///Solve a grid as efficiently as possible
    public mutating func solve() -> Set<Int>? {
        guard let column = columns.best else { return solution }
        for row in column {
            let cx = cover(row)
            let s = solve()
            uncover(row, cx)
            guard s == nil else { return s}
        }
        return nil
    }
    
    //MARK: - Partial
    ///Attempts to find valid partials without a master
    public mutating func partial(_ count: Int) -> Set<Int>? {
        var p = 0
        return partial(count, attemptedPartials: &p)
    }
    public mutating func partial(_ count: Int, attemptedPartials: inout Int) -> Set<Int>? {
        if count > 0 {
            attemptedPartials += 1
            print("Checking partial \(attemptedPartials)")
            if isValid() {
                return solution
            }
        }
        guard let column = columns.best else { return nil }
        for r in column {
            let cx = cover(r)
            let s = partial(count - 1)
            uncover(r, cx)
            guard s == nil else { return s }
        }
        return nil
    }
    //MARK: - Validators
    
    ///Check if grid is solvable without a specific row
    public mutating func isSolvable(without row: Int) -> Bool {
        guard let column = columns.best else { return true }
        for r in column where row != r {
            let cx = cover(r)
            let s = isSolvable(without: row)
            uncover(r, cx)
            guard !s else { return true }
        }
        return false
    }
    
    ///Check if there is only one solution to the partial (needs provided solution)
    public mutating func isValid(_ master: Set<Int>) -> Bool {
        guard let column = columns.best else { return master == solution }
        for row in column {
            let cx = cover(row)
            let s = isValid(master)
            uncover(row, cx)
            guard s else { return false }
        }
        return false
    }
    
    ///check if the puzzle is unique
    public mutating func isValid() -> Bool {
        return checkValid() ?? false
    }
    
    public mutating func checkValid() -> Bool? {
        guard let column = columns.best else { return true }
        var beenSolved: Bool? = nil
        for row in column {
            let cx = cover(row)
            let s = checkValid()
            uncover(row, cx)
            if let ss = s {
                if !ss { //not valid end now
                    return false
                }
                if beenSolved && ss { //two solutions not valid
                    return false
                }
                if ss {
                    beenSolved = true
                }
            }
        }
        return beenSolved
    }
    //MARK: - Convenience Methods
    
    ///Copy the struct and cover rows useful when reusing the Grid instead of constructing a new one
    public func copy(with rows: Set<Int>) -> XGrid {
        var n = self
        n.cover(rows)
        return n
    }
}
