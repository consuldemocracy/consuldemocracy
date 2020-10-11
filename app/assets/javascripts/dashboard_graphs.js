//= require d3
//= require c3
//= require c3ext

// TODO: This module is complex enough to require its own tests. Rewrite it using Ecma6 class syntax and
// write tests for this feature after consul has been migrated to Rails 5.1
(function() {
  "use strict";

  var ProposalGraph = function(url) {
    this.url = url;
    this.successfulProposalDataUrl = null;
    this.proposalAchievementsUrl = null;
    this.targetId = null;
    this.groupBy = null;
    this.proposalSuccess = null;
    this.maximumValue = 0;
    this.progressLabel = "Progress";
    this.supportsLabel = "Supports";
    this.successLabel = "Success";
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

  ProposalGraph.prototype.refreshGoals = function() {
    return $.ajax({
      url: this.resourcesUrl,
      cache: false,
      success: function(data) {
        this.parseGoals(data);
      }.bind(this)
    });
  };

  ProposalGraph.prototype.parseGoals = function(data) {
    this.goals = data.map(function(item) {
      return {
        value: item.required_supports,
        text: item.title
      };
    });
  };

  ProposalGraph.prototype.refreshData = function() {
    return $.ajax({
      url: this.url,
      cache: false,
      success: function(data) {
        this.parseData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseData = function(data) {
    var key;

    this.xColumnValues = [];
    this.progressColumnValues = [this.progressLabel];

    for (key in data) {
      if (Object.prototype.hasOwnProperty.call(data, key)) {
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
      success: function(data) {
        this.parseSuccessfulProposalData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseSuccessfulProposalData = function(data) {
    var key;

    this.successfulColumnValues = [this.successLabel];

    for (key in data) {
      if (Object.prototype.hasOwnProperty.call(data, key)) {
        this.addXColumnValue(key);
        this.successfulColumnValues.push(data[key]);
      }
    }
  };

  ProposalGraph.prototype.refreshAchievements = function() {
    return $.ajax({
      url: this.proposalAchievementsUrl,
      cache: false,
      success: function(data) {
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
      if (Object.prototype.hasOwnProperty.call(data, group)) {
        this.addXColumnValue(group);
        this.achievements.push({
          value: this.formatGroup(group),
          text: data[group].title,
          position: "start"
        });
      }
    }
  };

  ProposalGraph.prototype.addXColumnValue = function(value) {
    if (this.xColumnValues.indexOf(value) === -1) {
      this.xColumnValues.push(value);
    }
  };

  ProposalGraph.prototype.draw = function() {
    var colors = {},
      maximumValue = this.maximumValue === 0 ? this.proposalSuccess : Math.round(this.maximumValue * 1.10);

    this.formatXColumnValues();

    colors[this.progressColumnValues[0]] = "#004a83";
    colors[this.successfulColumnValues[0]] = "#ff7f0e";

    c3.generate({
      bindto: "#" + this.targetId,
      data: {
        x: "x",
        columns: [
          this.xColumnValues,
          this.progressColumnValues,
          this.successfulColumnValues
        ],
        colors: colors,
        color: function(color, d) {
          var achievement;

          if (d.id === this.successfulColumnValues[0] || !Object.prototype.hasOwnProperty.call(d, "x")) {
            return color;
          }

          achievement = this.achievements.find(function(element) {
            return element.value === this.xColumnValues[d.index + 1];
          }.bind(this));

          if (achievement !== undefined) {
            return "#ff0000";
          }

          return color;
        }.bind(this)
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
            position: "outer-middle"
          }
        },
        x: {
          type: "category",
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
      zoom: {
        enabled: true
      },
      tooltip: {
        format: {
          title: function(d) {
            var achievement = this.achievements.find(function(element) {
              return element.value === this.xColumnValues[d + 1];
            }.bind(this));

            if (achievement !== undefined) {
              return this.xColumnValues[d + 1] + ": " + achievement.text;
            }

            return this.xColumnValues[d + 1];
          }.bind(this)
        }
      }
    });
  };

  ProposalGraph.prototype.tickYValues = function() {
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

  ProposalGraph.prototype.tickXValues = function() {
    var i,
      l,
      tick = [],
      step = this.xColumnValues.length < 13 ? 1 : Math.round((this.xColumnValues.length - 1) / 12);

    if (this.xColumnValues.length > 1) {
      tick.push(0);

      for (i = step, l = this.xColumnValues.length - 1; i < l; i += step) {
        tick.push(i);
      }
    }

    return tick;
  };

  ProposalGraph.prototype.formatXColumnValues = function() {
    var i, l;

    this.xColumnValues = this.xColumnValues.sort();

    if (this.isDailyGrouped()) {
      for (i = 0, l = this.xColumnValues.length; i < l; i += 1) {
        this.xColumnValues[i] = this.formatGroup(this.xColumnValues[i]);
      }
    }

    this.xColumnValues.unshift("x");
  };

  ProposalGraph.prototype.formatGroup = function(group) {
    if (this.isDailyGrouped()) {
      var parts = group.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
      return parts[2] + "/" + parts[3];
    }

    return group;
  };

  ProposalGraph.prototype.isDailyGrouped = function() {
    return this.groupBy === undefined || this.groupBy === "" || this.groupBy === null;
  };

  $(function() {
    $("[data-proposal-graph-url]").each(function() {
      var graph = new ProposalGraph($(this).data("proposal-graph-url"));
      graph.successfulProposalDataUrl = $(this).data("successful-proposal-graph-url");
      graph.proposalAchievementsUrl = $(this).data("proposal-achievements-url");
      graph.targetId = $(this).attr("id");
      graph.groupBy = $(this).data("proposal-graph-group-by");
      graph.progressLabel = $(this).data("proposal-graph-progress-label");
      graph.supportsLabel = $(this).data("proposal-graph-supports-label");
      graph.successLabel = $(this).data("proposal-graph-success-label");
      graph.proposalSuccess = parseInt($(this).data("proposal-success"), 10);
      graph.resourcesUrl = $(this).data("proposal-resources-url");

      graph.refresh();
    });
  });
})();
