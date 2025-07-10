(function() {
  "use strict";
  // Helper for generate C3.js graphs
  //----------------------------------------------------------------------
  var buildGraph;

  buildGraph = function(el) {
    var conf, url;
    url = $(el).data("graph");
    conf = {
      bindto: el,
      data: {
        x: "x",
        url: url,
        mimeType: "json"
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
