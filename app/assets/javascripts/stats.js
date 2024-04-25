(function() {
  "use strict";
  // Helper for generate C3.js graphs
  //----------------------------------------------------------------------
  var buildGraph;

  buildGraph = function(el) {
    var conf;
    conf = {
      bindto: el,
      data: {
        x: "x",
        json: $(el).data("graph")
      },
      axis: {
        x: {
          type: "timeseries",
          tick: {
            format: "%Y-%m-%d"
          }
        }
      }
    };
    c3.generate(conf);
  };

  App.Stats = {
    initialize: function() {
      $("[data-graph]").each(function() {
        buildGraph(this);
      });
    }
  };
}).call(this);
