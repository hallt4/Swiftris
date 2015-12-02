//
//  Array2D.swift
//  Swiftris
//
//  Created by Tyler Hall on 11/18/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

// #define the array class
class Array2D<T> {
    let columns: Int
    let rows: Int
    // define the array property
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        // #instantiate the array
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
        
    }
    
    //Add array[column, row] functionality
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}

