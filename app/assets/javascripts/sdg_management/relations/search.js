(function() {
  "use strict";
  App.SDGManagementRelationSearch = {
    initialize: function() {
      App.SDGSyncGoalAndTargetFilters.sync($(".sdg-relations-search"));
    }
  };
}).call(this);
