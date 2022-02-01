(function() {
  "use strict";
  App.AdvancedSearch = {
    toggle_date_options: function() {
      if ($("#js-advanced-search-date-min").val() === "custom") {
        $("#js-custom-date").show();
        $(".js-calendar").datepicker("option", "disabled", false);
      } else {
        $("#js-custom-date").hide();
        $(".js-calendar").datepicker("option", "disabled", true);
      }
    },
    initialize: function() {
      var toggle_button = $("#js-advanced-search-title");

      toggle_button.removeAttr("hidden");

      if (toggle_button.attr("aria-expanded") === "true") {
        App.AdvancedSearch.toggle_date_options();
      } else {
        toggle_button.next().hide();
      }
      toggle_button.on({
        click: function() {
          $(this).attr("aria-expanded", !JSON.parse($(this).attr("aria-expanded")));
          $(this).next().slideToggle();
        }
      });
      $("#js-advanced-search-date-min").on({
        change: function() {
          App.AdvancedSearch.toggle_date_options();
        }
      });

      App.SDGSyncGoalAndTargetFilters.sync($("#advanced_search_form"));
    }
  };
}).call(this);
