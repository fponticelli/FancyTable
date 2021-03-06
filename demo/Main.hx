using dots.Dom;
import fancy.Table;
import fancy.table.*;
import fancy.table.util.Types;
import fancy.table.util.NestedData;
import fancy.table.util.CellContent;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using thx.Maps;
using thx.Tuple;

class Main {
  static function main() {
    var el = js.Browser.document.querySelector(".table-container");

    var cards = [{
      name : "Quarantine Field",
      color : "White",
      type : "Enchantment",
      rarity : "Mythic",
      multiverseId : "402001",
      cmc : 2,
      draftval : 5,
      tcgprice : 2.52
    }, {
      name : "Hero of Goma Fada",
      color : "White",
      type : "Creature",
      rarity : "Rare",
      multiverseId : "401913",
      cmc : 5,
      draftval : 3.5,
      tcgprice : 0.25
    }, {
      name : "Felidar Sovereign",
      color : "White",
      type : "Creature",
      rarity : "Rare",
      multiverseId : "401878",
      cmc : 6,
      draftval : 4,
      tcgprice : 0.56
    }, {
      name : "Part the Waterveil",
      color : "Blue",
      type : "Sorcery",
      rarity : "Mythic",
      multiverseId : "401982",
      cmc : 6,
      draftval : 2.0,
      tcgprice : 1.29
    }, {
      name : "Guardian of Tazeem",
      color : "Blue",
      type : "Creature",
      rarity : "Rare",
      multiverseId : "401906",
      cmc : 5,
      draftval : 4.5,
      tcgprice : 0.25
    }];

    function cardsToRowData(cards : Array<Card>, groupBy : Array<Card -> String>) : Array<RowData> {
      return cards.groupByAppend(groupBy[0], new Map()).tuples()
        .map(function (tuple) : RowData {
          var restOfGroupBys = groupBy.rest();

          // if there are no more groupBys, we're rendering actual cards
          return restOfGroupBys.length == 0 ? {
            values : tuple.right.map(function (card) : Array<CellContent> {
              return [
                Dom.create("span", [
                  Dom.create("span", card.name),
                  Dom.create("a", [
                    "href" => 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=${card.multiverseId}'
                  ], [
                    Dom.create("i.fa.fa-external-link-square")
                  ])
                ]),
                card.cmc, card.draftval, card.tcgprice
              ];
            }).flatten(),
            data : []
          } : {
            values : [tuple.left],
            data : cardsToRowData(tuple.right, restOfGroupBys)
          };
        });
    }

    function toRowData(cards : Array<Card>) : Array<RowData> {
      return ([{
        values : ["Cards", "CMC", "Draft Value", "Price"]
      }] : Array<RowData>).concat(cardsToRowData(cards, [
        function (card) return card.color,
        function (card) return card.rarity,
        function (card) return card.type,
        function (card) return card.name
      ]));
    }

    var table = Table.fromNestedData(el, {
      data : toRowData(cards),
      eachFold : function (row) {
        row.cells[0].onclick = function (_) {
          row.toggle();
        }
      }
    })
      // TODO: Currently affixing has to be done after setting cell click
      // handlers. Otherwise the cell gets cloned before the handler is set.
      // We could "fix" this by keeping a reference to each copied cell or
      // by handling event setting at the Table level
      .setFixedTop()
      .setFixedLeft();
  }
}

typedef Card = {
  name : String,
  color : String,
  type : String,
  rarity : String,
  multiverseId : String,
  cmc : Int,
  draftval : Float,
  tcgprice : Float
};
