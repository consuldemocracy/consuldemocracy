(function() {
  "use strict";
  App.ColumnsSelector = {
    initColumns: function() {
      var c_value, columns;
      App.ColumnsSelector.hideAll();
      c_value = App.ColumnsSelector.currentValue();
      if (c_value.length === 0) {
        c_value = $("#js-columns-selector").data("default");
        App.Cookies.saveCookie($("#js-columns-selector").data("cookie"), c_value, 30);
      }
      columns = c_value.split(",");
      columns.forEach(function(column) {
        $("[data-field=" + column + "]").removeClass("hidden");
        $("#column_selector_" + column).prop("checked", true);
      });
    },
    initChecks: function() {
      $(".column-selectable th[data-field]").each(function() {
        var field, input, item, label, text;
        field = $(this).data("field");
        text = $(this).text().trim();
        item = $("#column_selector_item_template").clone();
        item.prop("id", "column_selector_item_" + field);
        input = item.find("input");
        input.prop("name", "column-selector[" + field + "]");
        input.prop("id", "column_selector_" + field);
        input.data("column", field);
        label = item.find("label");
        label.prop("for", "column_selector_" + field);
        label.text(text);
        item.removeClass("hidden");
        $("#js-columns-selector-wrapper").append(item);
      });
    },
    toggleOptions: function(event) {
      event.preventDefault();
      $("#js-columns-selector").toggleClass("hollow");
      $("#js-columns-selector-wrapper").toggleClass("hidden");
    },
    hideAll: function() {
      $("[data-field]").addClass("hidden");
      $(".column-selector-item input").prop("checked", false);
    },
    toggleColumn: function(event) {
      App.ColumnsSelector.displayColumn($(event.target).data("column"));
    },
    displayColumn: function(column) {
      var value;
      if ($("#column_selector_" + column).prop("checked")) {
        $("[data-field=" + column + "]").removeClass("hidden");
      } else {
        $("[data-field=" + column + "]").addClass("hidden");
      }
      value = App.ColumnsSelector.updateItem(column);
      App.Cookies.saveCookie($("#js-columns-selector").data("cookie"), value, 30);
    },
    updateItem: function(value) {
      var index, values;
      values = App.ColumnsSelector.currentValue().split(",");
      index = values.indexOf(value);
      if (index >= 0) {
        values.splice(index, 1);
      } else {
        values.push(value);
      }
      return values.join(",");
    },
    currentValue: function() {
      return App.Cookies.getCookie($("#js-columns-selector").data("cookie"));
    },
    initialize: function() {
      App.ColumnsSelector.initChecks();
      App.ColumnsSelector.initColumns();
      $("#js-columns-selector").on({
        click: function(event) {
          App.ColumnsSelector.toggleOptions(event);
        }
      });
      $(".column-selector-item input").on({
        click: function(event) {
          App.ColumnsSelector.toggleColumn(event);
        }
      });
      $(".column-selectable").on("inserted", function() {
        App.ColumnsSelector.initColumns();
      });
    },
    destroy: function() {
      $("#js-columns-selector-wrapper").children(":not(#column_selector_item_template)").remove();
    }
  };
}).call(this);
