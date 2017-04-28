package fancy.table;

using thx.Nulls;

import fancy.table.util.CellContent;
import fancy.table.util.FancyTableClassOptions;
import fancy.table.util.FancyTableOptions;

import fancy.Grid;

typedef FancyTableClasses = {
  cellContent: String,
  rowExpanded: String,
  rowCollapsed: String,
  rowFoldHeader: String,
  rowIndent: String
}

class FancyTableSettings {
  public var fixedTop(default, null): Int;
  public var fixedLeft(default, null): Int;
  public var fallbackCell(default, null): CellContent;
  public var classes(default, null): FancyTableClasses;
  public var hSize(default, null): Int -> Int -> CellDimension;
  public var initialScrollX(default, null): HorizontalScrollPosition;
  public var initialScrollY(default, null): VerticalScrollPosition;

  public var onScroll(default, null) : ScrollEvent -> Void;
  public var onResize(default, null) : ResizeEvent -> Void;
  public var onFocus(default, null) : Table -> Void;
  public var onBlur(default, null) : Table -> Void;
  public var onKey(default, null): KeyEvent -> Void;
  public var onClick(default, null): CellEvent -> Void;
  public var onDoubleClick(default, null): CellEvent -> Void;
  public var onRangeChange(default, null): Table -> Void;

  // TODO !!! use
  public var canSelect(default, null): Int -> Int -> Bool;
  public var selectionEnabled(default, null): Bool;
  public var rangeSelectionEnabled(default, null): Bool;
  public var focusOnHover(default, null): Bool;

  function new(fixedTop, fixedLeft, fallbackCell, classes, hSize, initialX, initialY, canSelect, selectionEnabled, rangeSelectionEnabled, focusOnHover, onScroll, onResize, onFocus, onBlur, onKey, onClick, onDoubleClick, onRangeChange) {
    this.fixedTop = fixedTop;
    this.fixedLeft = fixedLeft;
    this.fallbackCell = fallbackCell;
    this.classes = classes;
    this.hSize = hSize;
    this.initialScrollX = initialX;
    this.initialScrollY = initialY;

    this.canSelect = canSelect;
    this.selectionEnabled = selectionEnabled;
    this.rangeSelectionEnabled = rangeSelectionEnabled;

    this.focusOnHover = focusOnHover;

    this.onScroll = onScroll;
    this.onResize = onResize;
    this.onFocus = onFocus;
    this.onBlur = onBlur;
    this.onKey = onKey;
    this.onDoubleClick = onDoubleClick;
    this.onClick = onClick;
    this.onRangeChange = onRangeChange;
  }

  static function classesFromOptions(?opts: FancyTableClassOptions): FancyTableClasses {
    if (opts == null) opts = {};

    return {
      cellContent: opts.cellContent != null ? opts.cellContent : "ft-cell-content",
      rowExpanded: opts.rowExpanded != null ? opts.rowExpanded : "ft-row-expanded",
      rowCollapsed: opts.rowCollapsed != null ? opts.rowCollapsed : "ft-row-collapsed",
      rowFoldHeader: opts.rowFoldHeader != null ? opts.rowFoldHeader : "ft-row-fold-header",
      rowIndent: opts.rowIndent != null ? opts.rowIndent : "ft-row-indent-"
    };
    // TODO !!! add classes for selections
  }

  public static function fromOptions(?opts: FancyTableOptions) {
    if (opts == null) opts = {};

/*
  ?canSelect: Int -> Int -> Bool,
  ?selectionEnabled: Bool,
  ?rangeSelectionEnabled: Bool,
  ?selection: Option<{ minRow: Int, minCol: Int, maxRow: Int, maxCol: Int}>
*/
    var fixedTop = opts.fixedTop.or(0),
        fixedLeft = opts.fixedLeft.or(0);
    return new FancyTableSettings(
      fixedTop,
      fixedLeft,
      opts.fallbackCell.or(CellContent.fromString("")),
      classesFromOptions(opts.classes),
      opts.hSize.or(function (_, _) return RenderSmart),
      opts.initialScrollX.or(Left),
      opts.initialScrollY.or(Top),
      opts.canSelect.or(function(r, c) return true),
      opts.selectionEnabled.or(true),
      opts.rangeSelectionEnabled.or(true),
      opts.focusOnHover.or(true),
      opts.onScroll.or(function(_) {}),
      opts.onResize.or(function(_) {}),
      opts.onFocus.or(function(_) {}),
      opts.onBlur.or(function(_) {}),
      opts.onKey.or(function(_) { }),
      opts.onClick.or(function(_) { }),
      opts.onDoubleClick.or(function(_) { }),
      opts.onRangeChange.or(function(_) { })
    );
  }
}
