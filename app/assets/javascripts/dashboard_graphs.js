//= require d3
//= require c3
//= require c3ext

(function(){
  'use strict';

  var ProposalGraph = function(url) {
    this.url = url;
    this.successfulProposalDataUrl = null;
    this.proposalAchievementsUrl = null;
    this.targetId = null;
    this.groupBy = null;
    this.proposalSuccess = null;
    this.maximumValue = 0;
    this.progressLabel = 'Progress';
    this.supportsLabel = 'Supports';
    this.successLabel = 'Success';
    this.goals = null;
    this.achievements = null;
    this.xColumnValues = null;
    this.progressColumnValues = null;
    this.resourcesUrl = null;
  };

  ProposalGraph.prototype.refresh = function() {
    this.refreshGoals()
      .then(this.refreshData.bind(this))
      .then(this.refreshSuccessfulData.bind(this))
      .then(this.refreshAchievements.bind(this))
      .done(this.draw.bind(this));
  };

  ProposalGraph.prototype.refreshGoals = function () {
    return $.ajax({
      url: this.resourcesUrl,
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
    
    this.xColumnValues = [ ];
    this.progressColumnValues =  [ this.progressLabel ];

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        this.xColumnValues.push(key);
        this.progressColumnValues.push(data[key]);

        if (this.maximumValue < data[key]) {
          this.maximumValue = data[key];
        }
      }
    }
  };

  ProposalGraph.prototype.refreshSuccessfulData = function() {
    return $.ajax({
      url: this.successfulProposalDataUrl,
      cache: false,
      success: function (data) {
        this.parseSuccessfulProposalData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseSuccessfulProposalData = function(data) {
    var key;
    
    this.successfulColumnValues = [ this.successLabel ];

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        this.addXColumnValue(key);
        this.successfulColumnValues.push(data[key]);
      }
    }
  };

  ProposalGraph.prototype.refreshAchievements = function() {
    return $.ajax({
      url: this.proposalAchievementsUrl,
      cache: false,
      success: function (data) {
        this.parseAchievements(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseAchievements = function(data) {
    var group;

    this.achievements = [];
    for (group in data) {
      if (data.hasOwnProperty(group)) {
        this.addXColumnValue(group);
        this.achievements.push({
          value: group,
          text: data[group].title
        });
      }
    }
  };

  ProposalGraph.prototype.addXColumnValue = function (value) {
    if (this.xColumnValues.indexOf(value) === -1) {
      this.xColumnValues.push(value);
    }
  };

  ProposalGraph.prototype.draw = function() {
    var colors = {},
        maximumValue = this.maximumValue === 0 ? this.proposalSuccess : Math.round(this.maximumValue * 1.10);

    this.formatXColumnValues();
    
    colors[this.progressColumnValues[0]] = '#004a83';
    colors[this.successfulColumnValues[0]] = '#ff7f0e';

    c3.generate({
      bindto: '#' + this.targetId,
      data: {
        x: 'x',
        columns: [
          this.xColumnValues,
          this.progressColumnValues,
          this.successfulColumnValues
        ],
        colors: colors
      },
      axis: {
        y: {
          tick: {
            values: this.tickYValues()
          },
          min: (this.maximumValue === 0 ? Math.round(this.proposalSuccess * 0.10) : 0),
          max: maximumValue,
          label: { 
            text: this.supportsLabel,
            position: 'outer-middle'
          }
        },
        x: {
          type: 'category',
          tick: {
            values: this.tickXValues(),
            centered: true
          }
        }
      },
      grid: {
        y: {
          lines: this.goals
        }
      },
      legend: {
        position: 'right'
      }
    });
  };

  ProposalGraph.prototype.tickYValues = function () {
    var i,
        tick = [0],
        maximumValue = this.maximumValue === 0 ? this.proposalSuccess : Math.round(this.maximumValue * 1.10),
        step = maximumValue <= 10 ? 1 : Math.round(maximumValue / 10);

    for (i = step; i < maximumValue; i += step) {
      tick.push(i);
    }

    tick.push(maximumValue);

    return tick;
  };

  ProposalGraph.prototype.tickXValues = function () {
    var i,
        l,
        tick = [],
        step = this.xColumnValues.length < 13 ? 1 : Math.round((this.xColumnValues.length - 1) / 12);

    if (this.xColumnValues.length > 1) {
      tick.push(0);

      for(i = step, l = this.xColumnValues.length - 1; i < l; i += step) {
        tick.push(i);
      }
    }

    return tick;
  };

  ProposalGraph.prototype.formatXColumnValues = function () {
    var i, l, parts;

    this.xColumnValues = this.xColumnValues.sort();

    if (this.isDailyGrouped()) {
      for (i = 0, l = this.xColumnValues.length; i < l; i += 1) {
        parts = this.xColumnValues[i].match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
        this.xColumnValues[i] = parts[2] + "/" + parts[3];
      }
    }

    this.xColumnValues.unshift('x');
  };

  ProposalGraph.prototype.isDailyGrouped = function() {
    return this.groupBy === undefined || this.groupBy === '' || this.groupBy === null
  };

  $(document).ready(function () {
    $('[data-proposal-graph-url]').each(function () {
      var graph = new ProposalGraph($(this).data('proposal-graph-url'));
      graph.successfulProposalDataUrl = $(this).data('successful-proposal-graph-url');
      graph.proposalAchievementsUrl = $(this).data('proposal-achievements-url');
      graph.targetId = $(this).attr('id');
      graph.groupBy = $(this).data('proposal-graph-group-by');
      graph.progressLabel = $(this).data('proposal-graph-progress-label');
      graph.supportsLabel = $(this).data('proposal-graph-supports-label');
      graph.successLabel = $(this).data('proposal-graph-success-label');
      graph.proposalSuccess = parseInt($(this).data('proposal-success'), 10);
      graph.resourcesUrl = $(this).data('proposal-resources-url');

      graph.refresh();
    });
  });
})();
