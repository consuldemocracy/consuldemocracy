//= require d3
//= require c3
//= require c3ext

(function(){
  'use strict';

  var ProposalGraph = function(url) {
    this.url = url;
    this.targetId = null;
    this.groupBy = null;
    this.proposalSuccess = null;
    this.progressLabel = 'Progress';
    this.supportsLabel = 'Supports';
    this.chart = null;
    this.goals = null;
    this.xColumnValues = null;
    this.progressColumnValues = null;
  };

  ProposalGraph.prototype.refresh = function() {
    this.refreshGoals()
      .then(this.refreshData.bind(this))
      .done(this.draw.bind(this));
  };

  ProposalGraph.prototype.refreshGoals = function () {
    return $.ajax({
      url: '/dashboard/resources.json',
      cache: false,
      success: function(data) {
        this.parseGoals(data);
      }.bind(this)
    });
  };

  ProposalGraph.prototype.parseGoals = function(data) {
    var i, l;

    this.goals = [];
    for (i = 0, l = data.length; i < l; i += 1) {
      this.goals.push({
        value: data[i].required_supports,
        text: data[i].title
      });
    }
  };

  ProposalGraph.prototype.refreshData = function () {
    return $.ajax({
      url: this.url,
      cache: false,
      success: function (data) {
        this.parseData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseData = function(data) {
    var key; 
    
    this.xColumnValues = [ 'x' ];
    this.progressColumnValues =  [ this.progressLabel ];

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        this.xColumnValues.push(key);
        this.progressColumnValues.push(data[key]);
      }
    }
  };

  ProposalGraph.prototype.draw = function(data) {
    this.chart = c3.generate({
      bindto: '#' + this.targetId,
      data: {
        x: 'x',
        columns: [
          this.xColumnValues,
          this.progressColumnValues
        ]
      },
      axis: {
        y: {
          min: 0,
          max: this.proposalSuccess,
          label: { 
            text: this.supportsLabel,
            position: 'outer-middle'
          }
        },
        x: {
          type: 'category'
        }
      },
      grid: {
        y: {
          lines: this.goals
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
      graph.proposalSuccess = parseInt($(this).data('proposal-success'), 10);

      graph.refresh();
    });
  });
})();
