//
//  File.swift
//  
//
//  Created by James Irwin on 9/6/20.
//

import Foundation

///A faster method then using dictionaries to organize columns
public struct DLXColumns {
    //MARK: - Public Properties
    
    public var indices: Set<Int>
    public var columns: [Set<Int>]
    public var counts: [Int]
    
    //MARK: - Computed Properties
    public var best: Set<Int>? {
        guard let i = indices.min(by:{counts[$0] < counts[$1]}) else {return nil}
        return sets[i]
    }
    
    public var random: Set<Int>? {
        guard let i = indices.randomElement() else { return nil }
        return sets[i]
    }
    //MARK: - Initializer
    
    init(_ count: Int) {
        indices = Set(0..<count)
        columns = [Set<Int>](repeating: [], count: count)
        counts = [Int](repeating: 0, count: count)
    }
    
    //MARK: - Subscript
    
    public subscript(index: Int) -> Set<Int>? {
        get{
            guard indices.contains(index) else { return nil }
            return columns[index]
        }
        
        set {
            guard let nv = newValue else {
                indices.remove(index)
                return
            }
            indices.insert(index)
            sets[index] = nv
        }
    }
    
    
    //MARK: - Mutators
    mutating func insert(_ row: Int, at index: Int) {
        indices.insert(index)
        sets[index].insert(row)
        counts[index] += 1
    }
    
    mutating func remove(_ row: Int, at index: Int) {
        sets[index].remove(row)
        counts[index] -= 1
    }
}
