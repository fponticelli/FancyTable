package fancy;

import fancy.table.*;
import fancy.table.util.Types;
using fancy.browser.Dom;
import js.html.Element;
using thx.Arrays;
using thx.Functions;
using thx.Ints;
using thx.Objects;
using thx.Tuple;

/**
  Create a new FancyTable by instantiating the `Table` class. A table instance
  provides you with read-only access to its rows, as well as methods for adding
  rows, modifying data, creating folds, and more. Instance methods generally
  return the instance of the table for easy chaining.
**/
class Table {
  public var rows(default, null) : Array<Row>;
  var tableEl : Element;
  var settings : FancyTableOptions;
  var grid : GridContainer;
  var folds : Array<Tuple2<Int, Int>>;

  // ints to track how many rows/cols are fixed in various places
  var fixedTop : Int;
  var fixedLeft : Int;

  /**
    A container element must be provided to the constructor. You may also
    provide an options object, though the only property you may wish to set with
    this object is the initial data.
  **/
  public function new(parent : Element, ?options : FancyTableOptions) {
    this.settings = createDefaultOptions(options);

    // create lots of dom
    tableEl = Dom.create("div.ft-table");
    grid = new GridContainer();
    tableEl.appendChild(grid.grid);

    // and fix the scrolling
    tableEl.on("scroll", function (_) {
      grid.positionPanes(tableEl.scrollTop, tableEl.scrollLeft);
    });

    // fill with any data
    setData(settings.data);

    // and add all of our shiny new dom to the parent
    parent.appendChild(tableEl);
  }

  function createDefaultOptions(?options : FancyTableOptions) {
    return Objects.merge({
      colCount : 0,
      data : ([[]] : Array<Array<String>>)
    }, options == null ? {} : options);
  }

  function empty() : Table {
    grid.empty();
    rows = [];
    folds = [];
    fixedTop = 0;
    fixedLeft = 0;
    this.settings.data = [];
    return setColCount(0);
  }

  /**
    Fills the table with entirely new data. This method completely empties the
    table and creates new rows and columns given the provided data.

    Note that this will remove any existing folds and fixed headers. It will
    also empty all table elements from the DOM and recreate them.
  **/
  public function setData(?data : Array<Array<String>>) : Table {
    empty();

    data = data != null ? data : [];

    return data.reduce(function(table : Table, curr : Array<String>) {
      var row = curr.reduce(function (row : Row, val : String) {
        return row.appendCell(new Cell(val));
      }, new Row());

      return table.appendRow(row);
    }, this);
  }

  /**
    Inserts a new row at any given index. If no row is provided, an empty row
    will be created.

    Note that for now, the inserted row won't obey any existing fixed row/col
    instructions you provided. If possible, add all rows before setting fixed
    headers.
  **/
  public function insertRowAt(index : Int, ?row : Row) : Table {
    // TODO: if you're inserting a row within the range of the affixed header
    // rows, we need to re-create the header table
    // ALSO TODO: we need to grab the first n cells in the new row and add them
    // to the affixed header column table (where n = number of affixed cells)
    row = row == null ? new Row({colCount : settings.colCount}) : row;

    // if our new row has fewer cols than everybody else, fill it
    row.fillWithCells(Ints.max(0, settings.colCount - row.cells.length));

    // but if it has more than everybody else, fill those and increase our count
    setColCount(row.cells.length);

    rows.insert(index, row);
    grid.content.insertAtIndex(row.el, index);
    return this;
  }

  /**
    Inserts a new row before all existing rows. If no row is provided, an empty
    row will be created.
  **/
  public function prependRow(?row : Row) : Table {
    return insertRowAt(0, row);
  }

  /**
    Inserts a new row after all existing rows. If no row is provided, an empty
    row will be created.
  **/
  public function appendRow(?row : Row) : Table {
    return insertRowAt(rows.length, row);
  }

  function setColCount(howMany : Int) : Table {
    if (howMany > settings.colCount) {
      rows.map(function(row) {
        row.fillWithCells(howMany - settings.colCount);
      });

      tableEl.removeClass('ft-table-${settings.colCount}-col').addClass('ft-table-$howMany-col');
      settings.colCount = howMany;
    }
    return this;
  }

  /**
    Creates a fixed header row at the top. Note that it's your responsibility
    to make sure things don't get weird if you also fold rows at the top. Any
    folded child rows won't automatically become affixed if you fix the parent.
  **/
  public function setFixedTop(?howMany = 1) : Table {
    // TODO: if howmany < the previous value, the hidden cells in the previously
    // hidden rows will not show up. we need to go through and clean up
    for (i in Ints.min(howMany, fixedTop)...Ints.max(howMany, fixedTop)) {
      // rows[i]
      // cells[i].fixed = howMany > fixedTop;
    }

    // empty existing fixed-row table
    grid.top
      .empty()
      .append(0.range(howMany).map(function (i) {
        return rows[i].copy().el;
      }));

    fixedTop = howMany;
    return updateFixedTopLeft();
  }

  /**
    Creates a fixed header column on the left. You can optionally specify more
    than one column to be fixed.
  **/
  public function setFixedLeft(?howMany = 1) : Table {
    grid.left
      .empty()
      .append(rows.map(function (row) {
        return row.updateFixedCells(howMany);
      }));

    fixedLeft = howMany;
    return updateFixedTopLeft();
  }

  function updateFixedTopLeft() : Table {
    grid.topLeft
      .empty()
      .append(0.range(fixedTop).map(function (i) {
        return rows[i].copy().updateFixedCells(fixedLeft);
      }));
    return this;
  }

  static function foldsIntersect(a : Tuple2<Int, Int>, b: Tuple2<Int, Int>) : Bool {
    // sort by the index of the header
    var first = a._0 <= b._0 ? a : b,
        second = first == a ? b : a;

    return first._0 < second._0 && // no problem if they start at the same spot
           second._0 <= first._0 + first._1 && // or if second starts after the end of first
           second._0 + second._1 > first._0 + first._1; // or if second ends before first ends
  }

  /**
    While data in your table is structurally rectangular, you can use folds to
    imply nesting. Specify an index of the header row (the one that will still
    be visible when the content is folded), as well as a count of how many rows
    following the header will be nested below it.

    Folds can be infinitely nested, but they can't intersect (e.g. you can't
    specify a fold from 0-4 and another from 2-6, because that doesn't make
    sense).
  **/
  public function createFold(headerIndex : Int, childrenCount : Int) {
    // check for out-of-range indexes
    if (headerIndex >= rows.length)
      return throw 'Cannot set fold point at $headerIndex because there are only ${rows.length} rows';

    childrenCount = Ints.min(childrenCount, rows.length - headerIndex);

    // folds can contain others, but they can't partially overlap
    for (fold in folds) {
      if (fold._0 == headerIndex) {
        return throw 'Cannot set fold point at $headerIndex because that row is already a fold header';
      }
      if (foldsIntersect(fold, new Tuple2(headerIndex, childrenCount))) {
        return throw 'Cannot set fold point at $headerIndex because it intersects with an existing fold';
      }
    }

    // finally, if we've made it this far, set up the fold
    for (i in (headerIndex + 1)...(childrenCount + headerIndex + 1)) {
      rows[i].indent();
      rows[headerIndex].addChildRow(rows[i]);
    }
    folds.push(new Tuple2(headerIndex, childrenCount));

    return setFixedLeft(fixedLeft);
  }

  /**
    Sets the string value of a cell given the 0-based index of the row and the
    0-based index of the cell within that row.
  **/
  public function setCellValue(row : Int, cell : Int, value : String) : Table {
    rows[row].setCellValue(cell, value);
    return this;
  }
}
