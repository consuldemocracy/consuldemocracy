App.Custom = {
  initialize: function() {
    var checkboxResults = $('#checkbox_results');
    var whenShowResults = $('#when_show_results');
    var checkboxStats = $('#checkbox_stats');
    var whenShowStats = $('#when_show_stats');
    if (checkboxResults != null) {
      if (checkboxResults.prop('checked') == true) {
        whenShowResults.prop('style').cssText = "display:show";
      }
      checkboxResults.change(function() {
        if(this.checked) {
          whenShowResults.prop('style').cssText = "display:show";
        } else {
          whenShowResults.prop('style').cssText = "display:none";
        }
      });
    }
    if (checkboxStats != null) {
      if (checkboxStats.prop('checked') == true) {
        whenShowStats.prop('style').cssText = "display:show";
      }
      checkboxStats.change(function() {
         if(this.checked) {
           whenShowStats.prop('style').cssText = "display:show";
         } else {
           whenShowStats.prop('style').cssText = "display:none";
         }
      });
    }
    return false;
  }
};
