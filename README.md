# SwiftlyDLX

[Donald Knuth's Paper on DLX](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwj40P3IwNTrAhWnr1kKHYAXC_EQFjALegQIBhAB&url=https%3A%2F%2Fwww.ocf.berkeley.edu%2F~jchu%2Fpublicportal%2Fsudoku%2F0011047.pdf&usg=AOvVaw3hMFp30TcjgvO-N1TvWQuQ)
Swiftly DLX is a Swift Package that was motivated by Knuth's Dancing links algorithm or algorithm X. Knuth uses a node list to effectively handle quick inserts and removals from the grid I have found Sets in swift are more performant. this would be closest to the [AlgorithmX in 30 lines](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiQwoWowdTrAhWRq1kKHQaCBJIQFjAAegQIAxAB&url=https%3A%2F%2Fwww.cs.mcgill.ca%2F~aassaf9%2Fpython%2Falgorithm_x.html&usg=AOvVaw0tDetzkFY_XhBe_9sjgP3O) However in that respect dictionaries are not as performant in swift as they appear to be in Python. I have built this a number of ways, using NodeLists, Dictionaries, and Sets/Arrays. The current implementation is the most performant method I have found however if you find a more performant method please let me know.

I tried to keep this generic so it can be used to solve a number of exact cover problems. Just an example here is the implementation to build a sudoku solver using this Algorithm

```swift
var grid = XGrid(729, 324){ index in 
    let value = index % 9
    let column = (index/9)%9
    let row = (index/81)%9
    let box = ((row/3) * 3) + (column/3)
    return [
        (row*9)+column,
        (row*9)+value+81,
        (column*9)+value+162,
        (box*9)+value+243
    ]
}

```

There is a second initializer in which you provide the number of columns and a [Set<Int>] which each set represents a row and each number in the set represents an intersecting column, while it constructs faster it requires either manual construction or a static value. in the case of sudoku that is a very large array.

## XGrid.fill(count:Int) -> Set<Int>?
attempt to solve the grid the first n values will be picked at random

## XGrid.solve() -> Set<Int>?
attempt to solve the grid as efficiently as possilbe

## XGrid.cover(row:Int) -> Set<Int>?
add the selected row to the solution and remove this row and all intersecting rows from the grid
**There is a multiple cover function as well for prepping a partial**

## XGrid.uncover(row:Int, intersectingRows:Set<Int>) -> Set<Int>?
remove the row from the solution and insert the row and provided intersecting rows into the grid
**There is a multiple uncover function I would recommend only using it with the returned value from the multiple cover function**

### A quick not about uncover and cover
because I am not using nodelists which require a reference be maintained so garbage collection does not remove them order is not as important however covered rows must still be uncovered in the inverse order that they were covered in or the grid will lose its integrity.

## XGrid.isSolvable(without row:Int) -> Bool
Check if removing a row makes puzzle unsolvable

## XGrid.isValid(master:Set<Int>) -> Bool
Check if the master is the only solution for the given partial.

## XGrid.copy(with rows: Set<Int>) -> XGrid
This will copy the grid to a new instance and cover the provided rows. This is particularly useful because it is faster to copy a struct instead of recreating it. In cases where you are trying to reduce a solution to its minimum provided partial this method will allow you to design the exact cover grid. then fill it over and over without having to reconstruct every iteration.

I built this for fun I hope you guys enjoy it. if you notice any bugs please let me know. also If you have any ideas I encourage you to let me know or submit a pull request.

I am curious what practical applications this algorithm has (There are a ton). If you use this code I would love for you to send me the name of the App/Program and its icon
