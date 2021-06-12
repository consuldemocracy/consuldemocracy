(function() {
  "use strict";
  App.AdvancedSearch = {
    advanced_search_terms: function() {
      return $("#js-advanced-search").data("advanced-search-terms");
    },
    toggle_form: function(event) {
      event.preventDefault();
      $("#js-advanced-search").slideToggle();
    },
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
      if (App.AdvancedSearch.advanced_search_terms()) {
        $("#js-advanced-search").show();
        App.AdvancedSearch.toggle_date_options();
      }
      $("#js-advanced-search-title").on({
        click: function(event) {
          App.AdvancedSearch.toggle_form(event);
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
