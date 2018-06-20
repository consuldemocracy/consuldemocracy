//= require d3
//= require c3
//= require c3ext

(function(){
  'use strict';

  var ProposalGraph = function(url) {
    this.url = url;
    this.targetId = null;
    this.groupBy = null;
    this.progressLabel = 'Progress';
    this.supportsLabel = 'Supports';
  };

  ProposalGraph.prototype.refresh = function() {
    $.ajax({
      url: this.url,
      cache: false,
      success: function (data) {
        this.draw(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.draw = function(data) {
    var xColumnValues = [ 'x' ],
      progressColumnValues =  [ this.progressLabel ], // [ '<%= t('.progress') %>' ],
      key;

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        xColumnValues.push(key);
        progressColumnValues.push(data[key]);
      }
    }

    c3.generate({
      bindto: '#' + this.targetId,
      data: {
        x: 'x',
        columns: [
          xColumnValues,
          progressColumnValues
        ]
      },
      axis: {
        y: {
          label: { 
            text: this.supportsLabel, // '<%= t '.supports' %> ',
            position: 'outer-middle'
          }
        },
        x: {
          type: 'category'
        }
      }
    });
  };

  $(document).ready(function () {
    $('[data-proposal-graph-url]').each(function () {
      var graph = new ProposalGraph($(this).data('proposal-graph-url'));
      graph.targetId = $(this).attr('id');
      graph.groupBy = $(this).data('proposal-graph-group-by');
      graph.progressLabel = $(this).data('proposal-graph-progress-label');
      graph.supportsLabel = $(this).data('proposal-graph-supports-label');

      graph.refresh();
    });
  });
})();

//  function drawProposalGraph(data) {
//    var xColumnValues = [ 'x' ],
//      progressColumnValues =  [ 'Progreso' ]; // [ '<%= t('.progress') %>' ],
//      key;
//
//    for (key in data) {
//      if (data.hasOwnProperty(key)) {
//        xColumnValues.push(key);
//        progressColumnValues.push(data[key]);
//      }
//    }
//
//    c3.generate({
//      bindto: '#proposal-graph',
//      data: {
//        x: 'x',
//        columns: [
//          xColumnValues,
//          progressColumnValues
//        ]
//      },
//      axis: {
//        y: {
//          label: { 
//            text: 'Apoyos', // '<%= t '.supports' %> ',
//            position: 'outer-middle'
//          }
//        },
//        x: {
//          type: 'category'
//        }
//      }
//    });
//  }
//
//  $(document).ready(function () {
//    $.ajax({
//      url: '<%= supports_proposal_dashboard_index_path(proposal, format: :json) %>',
//      cache: false,
//      success: function (data) {
//        drawProposalGraph(data);
//      },
//      data: {
//        group_by: '<%= params[:group_by] %>'
//      }
//    });
//  });
