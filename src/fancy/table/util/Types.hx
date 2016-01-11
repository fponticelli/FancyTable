package fancy.table.util;

typedef FancyTableOptions = {
  ?classes : FancyTableClasses,
  ?colCount : Int,
  ?data : Array<Array<String>>
};

typedef FancyTableClasses = {
  ?table : String,
  ?scrollH : String,
  ?scrollV : String
};

typedef FancyNestedTableOptions = {
  data : Array<RowData>,
  ?colCount : Int,
  ?eachFold : fancy.Table -> Int -> Void
}

typedef FancyRowOptions = {
  ?classes : FancyRowClasses,
  ?colCount : Int,
  ?expanded : Bool,
  ?hidden : Bool,
  ?fixedCellCount : Int,
  ?indentation : Int
};

typedef FancyRowClasses = {
  ?row : String,
  ?expanded : String,
  ?collapsed : String,
  ?foldHeader : String,
  ?hidden : String,
  ?indent : String,
  ?custom : String
};

typedef RowData = {
  values : Array<String>,
  ?data : Array<RowData>,
  ?meta : {
    ?classes : Array<String>,
    ?collapsed : Bool
  }
};

enum CellFormatting {
  number;
  date;
  currency;
  string;
}
