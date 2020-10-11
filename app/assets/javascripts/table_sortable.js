(function() {
  "use strict";
  App.TableSortable = {
    getCellValue: function(row, index) {
      return $(row).children("td").eq(index).text();
    },
    comparer: function(index) {
      return function(a, b) {
        var valA, valB;
        valA = App.TableSortable.getCellValue(a, index);
        valB = App.TableSortable.getCellValue(b, index);
        if ($.isNumeric(valA) && $.isNumeric(valB)) {
          return valA - valB;
        } else {
          return valA.localeCompare(valB);
        }
      };
    },
    initialize: function() {
      $(".table-sortable th").on("click", function() {
        var rows, table;
        table = $(this).parents("table").eq(0);
        rows = table.find("tbody tr").toArray().sort(App.TableSortable.comparer($(this).index()));
        this.asc = !this.asc;
        if (this.asc) {
          table.append(rows);
        } else {
          table.append(rows.reverse());
        }
      });
    }
  };
}).call(this);
