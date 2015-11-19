// Generated by Haxe
(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,replace: function(s,by) {
		return s.replace(this.r,by);
	}
};
var HxOverrides = function() { };
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Main = function() { };
Main.main = function() {
	var el = window.document.querySelector(".table-container");
	var data = [{ values : ["Cards","CMC","Draft Value","Price"]},{ values : ["White"], data : [{ values : ["Mythic"], data : [{ values : ["Enchantment"], data : [{ values : ["Quarantine Field","2","5","2.52"]}]}]},{ values : ["Rare"], data : [{ values : ["Creature"], data : [{ values : ["Hero of Goma Fada","5","3.5","0.27"]},{ values : ["Felidar Sovereign","6","4","0.56"]}]}]}]},{ values : ["Blue"], data : [{ values : ["Mythic"], data : [{ values : ["Sorcery"], data : [{ values : ["Part the Waterveil","6","2.0","1.29"]}]}]},{ values : ["Rare"], data : [{ values : ["Creature"], data : [{ values : ["Guardian of Tazeem","5","4.5","0.25"]}]}]}]}];
	var table1 = thx_Arrays.reduce(Main.rectangularize(data),function(table,curr) {
		var row1 = thx_Arrays.reducei(curr,function(row,val,index) {
			return row.setCellValue(index,val);
		},new fancy_table_Row(null,{ colCount : 4}));
		return table.appendRow(row1);
	},new fancy_Table(el));
	thx_Arrays.reduce(Main.createFolds(data)._1,function(table2,fold) {
		table2.rows[fold._0].cells[0].set_onclick(function(_) {
			table2.rows[fold._0].toggle();
		});
		return table2.createFold(fold._0,fold._1);
	},table1).setFixedTop().setFixedLeft();
};
Main.createFolds = function(data,start) {
	if(start == null) start = 0;
	return data.reduce(function(acc,row,index) {
		acc._0++;
		if(row.data != null) {
			var result = Main.createFolds(row.data,acc._0 + start);
			acc._1.push({ _0 : acc._0 + start - 1, _1 : result._0});
			acc._0 += result._0;
			acc._1 = acc._1.concat(result._1);
		}
		return acc;
	},{ _0 : 0, _1 : []});
};
Main.rectangularize = function(data) {
	return data.reduce(function(acc,d) {
		acc.push(d.values);
		if(d.data != null) return acc.concat(Main.rectangularize(d.data)); else return acc;
	},[]);
};
var Reflect = function() { };
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
var fancy_Table = function(parent,options) {
	var _g = this;
	var tableEl;
	this.settings = this.createDefaultOptions(options);
	this.rows = [];
	this.folds = [];
	this.fixedTop = 0;
	this.fixedLeft = 0;
	tableEl = fancy_browser_Dom.create("div.ft-table");
	this.grid = new fancy_table_GridContainer();
	tableEl.appendChild(this.grid.grid);
	fancy_browser_Dom.on(tableEl,"scroll",function(_) {
		_g.grid.positionPanes(tableEl.scrollTop,tableEl.scrollLeft);
	});
	parent.appendChild(tableEl);
};
fancy_Table.foldsIntersect = function(a,b) {
	var first;
	if(a._0 <= b._0) first = a; else first = b;
	var second;
	if(first == a) second = b; else second = a;
	return first._0 < second._0 && second._0 <= first._0 + first._1 && second._0 + second._1 > first._0 + first._1;
};
fancy_Table.prototype = {
	createDefaultOptions: function(options) {
		return thx_Objects.combine({ colCount : 0},options == null?{ }:options);
	}
	,insertRowAt: function(index,row) {
		if(row == null) row = new fancy_table_Row(null,{ colCount : this.settings.colCount}); else row = row;
		this.rows.splice(index,0,row);
		fancy_browser_Dom.insertAtIndex(this.grid.content,row.el,index);
		return this;
	}
	,appendRow: function(row) {
		return this.insertRowAt(this.rows.length,row);
	}
	,setFixedTop: function(howMany) {
		if(howMany == null) howMany = 1;
		var _g = this;
		var _g1 = thx_Ints.min(howMany,this.fixedTop);
		var _g2 = thx_Ints.max(howMany,this.fixedTop);
		while(_g1 < _g2) {
			var i = _g1++;
		}
		fancy_browser_Dom.append(fancy_browser_Dom.empty(this.grid.top),null,thx_Ints.range(0,howMany).map(function(i1) {
			return _g.rows[i1].copy().el;
		}));
		this.fixedTop = howMany;
		return this.updateFixedTopLeft();
	}
	,setFixedLeft: function(howMany) {
		if(howMany == null) howMany = 1;
		fancy_browser_Dom.append(fancy_browser_Dom.empty(this.grid.left),null,this.rows.map(function(row) {
			return row.updateFixedCells(howMany);
		}));
		this.fixedLeft = howMany;
		return this.updateFixedTopLeft();
	}
	,updateFixedTopLeft: function() {
		var _g = this;
		fancy_browser_Dom.append(fancy_browser_Dom.empty(this.grid.topLeft),null,thx_Ints.range(0,this.fixedTop).map(function(i) {
			return _g.rows[i].copy().updateFixedCells(_g.fixedLeft);
		}));
		return this;
	}
	,createFold: function(headerIndex,childrenCount) {
		if(headerIndex >= this.rows.length) throw new js__$Boot_HaxeError("Cannot set fold point at " + headerIndex + " because there are only " + this.rows.length + " rows");
		childrenCount = thx_Ints.min(childrenCount,this.rows.length - headerIndex);
		var _g = 0;
		var _g1 = this.folds;
		while(_g < _g1.length) {
			var fold = _g1[_g];
			++_g;
			if(fold._0 == headerIndex) throw new js__$Boot_HaxeError("Cannot set fold point at " + headerIndex + " because that row is already a fold header");
			if(fancy_Table.foldsIntersect(fold,{ _0 : headerIndex, _1 : childrenCount})) throw new js__$Boot_HaxeError("Cannot set fold point at " + headerIndex + " because it intersects with an existing fold");
		}
		var _g11 = headerIndex + 1;
		var _g2 = childrenCount + headerIndex + 1;
		while(_g11 < _g2) {
			var i = _g11++;
			this.rows[i].indent();
			this.rows[headerIndex].addChildRow(this.rows[i]);
		}
		this.folds.push({ _0 : headerIndex, _1 : childrenCount});
		return this.setFixedLeft(this.fixedLeft);
	}
};
var fancy_browser_Dom = function() { };
fancy_browser_Dom.hasClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	return regex.match(el.className);
};
fancy_browser_Dom.addClass = function(el,className) {
	if(!fancy_browser_Dom.hasClass(el,className)) el.className += " " + className;
	return el;
};
fancy_browser_Dom.removeClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	el.className = regex.replace(el.className,"");
	return el;
};
fancy_browser_Dom.on = function(el,eventName,callback) {
	el.addEventListener(eventName,callback);
	return el;
};
fancy_browser_Dom.off = function(el,eventName,callback) {
	el.removeEventListener(eventName,callback);
	return el;
};
fancy_browser_Dom.create = function(name,attrs,children,textContent) {
	if(attrs == null) attrs = { };
	if(children == null) children = [];
	var classNames;
	if(Object.prototype.hasOwnProperty.call(attrs,"class")) classNames = Reflect.field(attrs,"class"); else classNames = "";
	var nameParts = name.split(".");
	name = nameParts.shift();
	if(nameParts.length > 0) classNames += " " + nameParts.join(" ");
	var el = window.document.createElement(name);
	var _g = 0;
	var _g1 = Reflect.fields(attrs);
	while(_g < _g1.length) {
		var att = _g1[_g];
		++_g;
		el.setAttribute(att,Reflect.field(attrs,att));
	}
	el.className = classNames;
	var _g2 = 0;
	while(_g2 < children.length) {
		var child = children[_g2];
		++_g2;
		el.appendChild(child);
	}
	if(textContent != null) el.appendChild(window.document.createTextNode(textContent));
	return el;
};
fancy_browser_Dom.insertAtIndex = function(el,child,index) {
	el.insertBefore(child,el.children[index]);
	return el;
};
fancy_browser_Dom.appendChild = function(el,child) {
	el.appendChild(child);
	return el;
};
fancy_browser_Dom.appendChildren = function(el,children) {
	return children.reduce(fancy_browser_Dom.appendChild,el);
};
fancy_browser_Dom.append = function(el,child,children) {
	if(child != null) fancy_browser_Dom.appendChild(el,child);
	return fancy_browser_Dom.appendChildren(el,children != null?children:[]);
};
fancy_browser_Dom.empty = function(el) {
	while(el.firstChild != null) el.removeChild(el.firstChild);
	return el;
};
var fancy_table_Cell = function(value,fixed,onclick) {
	if(fixed == null) fixed = false;
	this.el = fancy_browser_Dom.create("div.ft-cell",null,null,value);
	this.set_onclick(onclick != null?onclick:function(_) {
	});
	this.set_value(value);
	this.set_fixed(fixed);
};
fancy_table_Cell.prototype = {
	set_fixed: function(value) {
		if(value) fancy_browser_Dom.addClass(this.el,"ft-col-fixed"); else fancy_browser_Dom.removeClass(this.el,"ft-col-fixed");
		return this.fixed = value;
	}
	,set_value: function(value) {
		this.el.textContent = value;
		return this.value = value;
	}
	,set_onclick: function(fn) {
		fancy_browser_Dom.off(this.el,"click",this.onclick);
		fancy_browser_Dom.on(this.el,"click",fn);
		return this.onclick = fn;
	}
	,copy: function() {
		return new fancy_table_Cell(this.value,this.fixed,this.onclick);
	}
};
var fancy_table_GridContainer = function() {
	this.topLeft = fancy_browser_Dom.create("div.ft-table-fixed-top-left");
	this.top = fancy_browser_Dom.create("div.ft-table-fixed-top");
	this.left = fancy_browser_Dom.create("div.ft-table-fixed-left");
	this.content = fancy_browser_Dom.create("div.ft-table-content");
	this.grid = fancy_browser_Dom.create("div.ft-table-grid-contaienr");
	fancy_browser_Dom.append(fancy_browser_Dom.append(fancy_browser_Dom.append(fancy_browser_Dom.append(this.grid,this.topLeft),this.top),this.left),this.content);
};
fancy_table_GridContainer.prototype = {
	positionPanes: function(deltaTop,deltaLeft) {
		this.topLeft.style.top = "" + deltaTop + "px";
		this.topLeft.style.left = "" + deltaLeft + "px";
		this.top.style.top = "" + deltaTop + "px";
		this.left.style.left = "" + deltaLeft + "px";
	}
};
var fancy_table_Row = function(cells,options) {
	if(cells == null) this.cells = []; else this.cells = cells;
	this.settings = this.createDefaultOptions(options);
	this.settings.classes = this.createDefaultClasses(this.settings.classes);
	this.rows = [];
	this.el = this.createRowElement(this.cells);
	var colDiff = this.settings.colCount - this.cells.length;
	if(colDiff > 0) {
		var _g = 0;
		while(_g < colDiff) {
			var i = _g++;
			this.insertCell(i + this.cells.length);
		}
	}
};
fancy_table_Row.prototype = {
	createDefaultOptions: function(options) {
		return thx_Objects.combine({ classes : { }, colCount : 0, expanded : true, fixedCellCount : 0, indentation : 0},options == null?{ }:options);
	}
	,createDefaultClasses: function(classes) {
		return thx_Objects.combine({ row : "ft-row", values : "ft-row-values", expanded : "ft-row-expanded", collapsed : "ft-row-collapsed", foldHeader : "ft-row-fold-header", hidden : "ft-row-hidden", indent : "ft-row-indent-"},classes == null?{ }:classes);
	}
	,createRowElement: function(children) {
		var childElements = (children != null?children:[]).map(function(_) {
			return _.el;
		});
		return fancy_browser_Dom.addClass(fancy_browser_Dom.addClass(fancy_browser_Dom.addClass(fancy_browser_Dom.create("div." + this.settings.classes.row,{ },childElements),this.settings.expanded?this.settings.classes.expanded:this.settings.classes.collapsed),"" + this.settings.classes.indent + this.settings.indentation),this.rows.length == 0?"":this.settings.classes.foldHeader);
	}
	,updateFixedCells: function(count) {
		var _g = this;
		var _g1 = thx_Ints.min(count,this.settings.fixedCellCount);
		var _g2 = thx_Ints.max(count,this.settings.fixedCellCount);
		while(_g1 < _g2) {
			var i = _g1++;
			this.cells[i].set_fixed(count > this.settings.fixedCellCount);
		}
		this.settings.fixedCellCount = count;
		this.fixedEl = thx_Arrays.reduce(thx_Ints.range(0,count),function(parent,index) {
			var cell = _g.cells[index].copy();
			cell.set_fixed(false);
			return fancy_browser_Dom.append(parent,cell.el);
		},this.createRowElement());
		return this.fixedEl;
	}
	,insertCell: function(index,cell) {
		if(cell == null) cell = new fancy_table_Cell(); else cell = cell;
		this.cells.splice(index,0,cell);
		fancy_browser_Dom.insertAtIndex(this.el,cell.el,index);
		return this;
	}
	,addRowClass: function(className) {
		fancy_browser_Dom.addClass(this.el,className);
		if(this.fixedEl != null) fancy_browser_Dom.addClass(this.fixedEl,className);
		return this;
	}
	,removeRowClass: function(className) {
		fancy_browser_Dom.removeClass(this.el,className);
		if(this.fixedEl != null) fancy_browser_Dom.removeClass(this.fixedEl,className);
		return this;
	}
	,addChildRow: function(child) {
		this.addRowClass(this.settings.classes.foldHeader);
		this.rows.push(child);
	}
	,indent: function() {
		this.removeRowClass("" + this.settings.classes.indent + this.settings.indentation);
		this.settings.indentation++;
		this.addRowClass("" + this.settings.classes.indent + this.settings.indentation);
	}
	,expand: function() {
		var _g = this;
		this.settings.expanded = true;
		this.removeRowClass(this.settings.classes.collapsed).addRowClass(this.settings.classes.expanded);
		this.rows.map(function(row) {
			row.removeRowClass(_g.settings.classes.hidden);
		});
	}
	,collapse: function() {
		var _g = this;
		this.settings.expanded = false;
		this.removeRowClass(this.settings.classes.expanded).addRowClass(this.settings.classes.collapsed);
		this.rows.map(function(row) {
			row.addRowClass(_g.settings.classes.hidden);
		});
	}
	,toggle: function() {
		if(this.settings.expanded) this.collapse(); else this.expand();
	}
	,setCellValue: function(index,value) {
		if(index >= this.cells.length) throw new js__$Boot_HaxeError("Cannot set \"" + value + "\" for cell at index " + index + ", which does not exist");
		this.cells[index].set_value(value);
		return this;
	}
	,copy: function() {
		return new fancy_table_Row(this.cells.map(function(_) {
			return _.copy();
		}),this.settings);
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var thx_Arrays = function() { };
thx_Arrays.reduce = function(array,callback,initial) {
	return array.reduce(callback,initial);
};
thx_Arrays.reducei = function(array,callback,initial) {
	return array.reduce(callback,initial);
};
var thx_Ints = function() { };
thx_Ints.max = function(a,b) {
	if(a > b) return a; else return b;
};
thx_Ints.min = function(a,b) {
	if(a < b) return a; else return b;
};
thx_Ints.range = function(start,stop,step) {
	if(step == null) step = 1;
	if(null == stop) {
		stop = start;
		start = 0;
	}
	if((stop - start) / step == Infinity) throw new js__$Boot_HaxeError("infinite range");
	var range = [];
	var i = -1;
	var j;
	if(step < 0) while((j = start + step * ++i) > stop) range.push(j); else while((j = start + step * ++i) < stop) range.push(j);
	return range;
};
var thx_Objects = function() { };
thx_Objects.combine = function(first,second) {
	var to = { };
	var _g = 0;
	var _g1 = Reflect.fields(first);
	while(_g < _g1.length) {
		var field = _g1[_g];
		++_g;
		Reflect.setField(to,field,Reflect.field(first,field));
	}
	var _g2 = 0;
	var _g11 = Reflect.fields(second);
	while(_g2 < _g11.length) {
		var field1 = _g11[_g2];
		++_g2;
		Reflect.setField(to,field1,Reflect.field(second,field1));
	}
	return to;
};
if(Array.prototype.map == null) Array.prototype.map = function(f) {
	var a = [];
	var _g1 = 0;
	var _g = this.length;
	while(_g1 < _g) {
		var i = _g1++;
		a[i] = f(this[i]);
	}
	return a;
};

      // Production steps of ECMA-262, Edition 5, 15.4.4.21
      // Reference: http://es5.github.io/#x15.4.4.21
      if (!Array.prototype.reduce) {
        Array.prototype.reduce = function(callback /*, initialValue*/) {
          'use strict';
          if (this == null) {
            throw new TypeError('Array.prototype.reduce called on null or undefined');
          }
          if (typeof callback !== 'function') {
            throw new TypeError(callback + ' is not a function');
          }
          var t = Object(this), len = t.length >>> 0, k = 0, value;
          if (arguments.length == 2) {
            value = arguments[1];
          } else {
            while (k < len && ! k in t) {
              k++;
            }
            if (k >= len) {
              throw new TypeError('Reduce of empty array with no initial value');
            }
            value = t[k++];
          }
          for (; k < len; k++) {
            if (k in t) {
              value = callback(value, t[k], k, t);
            }
          }
          return value;
        };
      }
    ;
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
