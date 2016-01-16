package fancy.table.util;

import fancy.table.util.Types;
using thx.Arrays;
import thx.Tuple;

class NestedData {
  /**
    Converts a nested `RowData` structure into a flat array of array of strings,
    which can be used to set complete table data from scratch.
  **/
  public static function rectangularize(data : Array<RowData>) : Array<Array<CellContent>> {
    return data.reduce(function (acc : Array<Array<CellContent>>, d : RowData) {
      acc.push(d.values);
      return d.data != null ? acc.concat(rectangularize(d.data)) : acc;
    }, []);
  }

  /**
    Recursively iterates over the nested data in the given array of `RowData`,
    calling the provided callback function for each value. The callback receives
    the `RowData` value at this point, as well as the total count of rows that
    have been encountered so far.
  **/
  public static function iterate(data : Array<RowData>, fn : RowData -> Int -> Void, ?start = 0) {
    return data.reduce(function (acc : Int, row : RowData) {
      fn(row, acc);

      acc++;
      return row.data != null ? iterate(row.data, fn, acc) : acc;
    }, start);
  }


  /**
    Given an array of (nested) row data, this function returns a tuple with fold
    information. The left side of the resulting tuple is the number of rows
    processed. The right side of the tuple is an array of fold tuples. The left
    side of the fold tuple is a header row index, and the right side is a count
    of how many rows should be folded under it.

    ```haxe
      // generate folds, then iterate over the array of fold tuples
      generateFolds(data).right.reduce(function (fold) {
        return table.createFold(fold.left, fold.right)
      }, table); // assumes you already have a table to start with
    ```
  **/
  public static function generateFolds(data : Array<RowData>, ?start = 0) : Tuple2<Int, Array<Tuple2<Int, Int>>> {
    return data.reducei(function (acc : Tuple2<Int, Array<Tuple2<Int, Int>>>, row : RowData, index) {
      // always increment the row count
      acc._0++;

      // if there's nested data, dig deep
      if (row.data != null) {
        var result = generateFolds(row.data, acc._0 + start);
        acc._1.push(new Tuple2(acc._0 + start - 1, result._0));
        acc._0 += result._0;
        acc._1 = acc._1.concat(result._1);
      }

      return acc;
    }, new Tuple2(0, []));
  }

  /**
    Takes two folds and determines if they overlap one another, where a fold is
    a tuple of two ints. The left part is the index of the header row, and the
    right part is the count of rows folded under the header.

    e.g: `foldsIntersect(new Tuple(0, 3), new Tuple(2,6))` is true because the
    folds are not completely contained or completely separate. The two folds
    share some rows, and are overlapping or intersecting as a result.
  **/
  public static function foldsIntersect(a : Tuple2<Int, Int>, b: Tuple2<Int, Int>) : Bool {
    // sort by the index of the header
    var first = a._0 <= b._0 ? a : b,
        second = first == a ? b : a;

    return first._0 < second._0 && // no problem if they start at the same spot
           second._0 <= first._0 + first._1 && // or if second starts after the end of first
           second._0 + second._1 > first._0 + first._1; // or if second ends before first ends
  }
}
