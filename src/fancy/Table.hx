package fancy;

import fancy.table.*;
using fancy.table.util.NestedData;
import fancy.table.util.Types;
import fancy.table.util.CellContent;
using dots.Dom;
import js.html.Element;
import js.html.Node;
using thx.Arrays;
using thx.Functions;
import thx.Ints;
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
    settings = createDefaultOptions(options);
    settings.classes = createDefaultClasses(settings.classes);

    // create lots of dom
    tableEl = Dom.create("div").addClass(settings.classes.table);
    grid = new GridContainer();
    tableEl.appendChild(grid.el);

    // and fix the scrolling
    tableEl.on("scroll", function (_) {
      grid.positionPanes(tableEl.scrollTop, tableEl.scrollLeft);

      if (tableEl.scrollTop == 0) tableEl.removeClass(settings.classes.scrollV);
      else tableEl.addClass(settings.classes.scrollV);

      if (tableEl.scrollLeft == 0) tableEl.removeClass(settings.classes.scrollH);
      else tableEl.addClass(settings.classes.scrollH);
    });

    // fill with any data
    setData(settings.data);

    // and add all of our shiny new dom to the parent
    parent.appendChild(tableEl);
  }

  function createDefaultOptions(?options : FancyTableOptions) : FancyTableOptions {
    return Objects.merge({
      classes : {},
      colCount : 0,
      data : []
    }, options == null ? ({} : FancyTableOptions) : options);
  }

  function createDefaultClasses(?classes : FancyTableClasses) {
    return Objects.merge({
      table : "ft-table",
      scrollH : "ft-table-scroll-horizontal",
      scrollV : "ft-table-scroll-vertical"
    }, classes == null ? {} : classes);
  }

  function empty() : Table {
    tableEl.empty();
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
  public function setData(?data : Array<Array<CellContent>>) : Table {
    data = data != null ? data : [];

    return data.reduce(function(table : Table, curr : Array<CellContent>) {
      var row = curr.reduce(function (row : Row, val : CellContent) {
        return row.appendCell(new Cell(val));
      }, new Row());

      return table.appendRow(row);
    }, this.empty());
  }

  /**
    Uses `setData()` internally, but also adds classes and creates folds given
    nested data instead of just strings.
  **/
  public function setNestedData(data : Array<RowData>, ?eachFold : Row -> Void) {
    empty();
    appendRowsWithChildren(data.toRows(eachFold));
    tableEl.appendChild(grid.el);
    return this;
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

  function appendRowsWithChildren(rows : Array<Row>) {
    return rows.reduce(function (table : Table, row) {
      table.appendRow(row);
      return appendRowsWithChildren(row.rows);
    }, this);
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
    }
    tableEl.removeClass('ft-table-${settings.colCount}-col').addClass('ft-table-$howMany-col');
    settings.colCount = howMany;
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
      .append(rows.slice(0, howMany).map(function (row) : Node {
        return row.copy().el;
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
      .append(rows.map(function (row) : Node {
        return row.updateFixedCells(howMany);
      }));

    fixedLeft = howMany;
    return updateFixedTopLeft();
  }

  function updateFixedTopLeft() : Table {
    grid.topLeft
      .empty()
      .append(rows.slice(0, fixedTop).map(function (row) : Node {
        // FIXME: this copies all rows in `fixedTop`, even if nothing needs
        // to be fixed left
        return row.copy().updateFixedCells(fixedLeft);
      }));
    return this;
  }
  /**
    Sets the value of a cell given the 0-based index of the row and the 0-based
    index of the cell within that row. Cells can have strings, numbers, or html
    elements as content.
  **/
  public function setCellValue(row : Int, cell : Int, value : CellContent) : Table {
    rows[row].setCellValue(cell, value);
    return this;
  }

  /**
    Creates a table instance from nested data, rather than rectangular data.
    This automatically digs through the nested structure, creating folds as
    needed.
  **/
  public static function fromNestedData(parent : Element, options : FancyNestedTableOptions) : Table {
    return new Table(parent).setNestedData(options.data, options.eachFold);
  }
}
