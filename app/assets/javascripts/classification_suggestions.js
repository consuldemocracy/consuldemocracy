(function() {
  "use strict";

  var CS;

  CS = App.ClassificationSuggestions = {
    panelSelector: ".classification-suggestions-tags, .classification-suggestions-sdgs",
    appliedClasses: "is-applied hide",
    remainingSelector: ".classification-suggestion:not(.is-applied)",
    initialize: function() {
      $("body").on("click", ".suggest-classification", function() {
        CS.requestSuggestions($(this));
      });

      $("body").on("click", ".classification-suggestion", function() {
        CS.applySuggestion($(this));
      });

      $("body").on("click", ".classification-accept-all", function() {
        var $panel = $(this).closest(CS.panelSelector);

        CS.remainingSuggestions($panel).each(function() {
          CS.applySuggestion($(this));
        });
      });

      $("body").on("click", ".classification-dismiss", function() {
        CS.dismissPanel($(this).closest(CS.panelSelector));
      });
    },
    panelsFor: function($form) {
      return {
        tags: $form.find(".classification-suggestions-tags"),
        sdgs: $form.find(".classification-suggestions-sdgs")
      };
    },
    requestSuggestions: function($button) {
      var $form = $button.closest("form");
      var resourceType = $button.data("resource-type");
      var panels = CS.panelsFor($form);
      var params;

      if (CS.restorePanelsIfCached(panels.tags, panels.sdgs)) {
        return;
      }

      $button.prop("disabled", true);
      $button.addClass("is-loading");
      CS.showPanelMessage(panels.tags, panels.tags.data("loading"));
      CS.showPanelMessage(panels.sdgs, panels.sdgs.data("loading"));

      if (typeof CKEDITOR !== "undefined") {
        for (var name in CKEDITOR.instances) {
          if (Object.prototype.hasOwnProperty.call(CKEDITOR.instances, name)) {
            CKEDITOR.instances[name].updateElement();
          }
        }
      }

      params = $form.serializeArray().filter(function(item) {
        return item.name !== "_method";
      });
      params.push({ name: "resource_type", value: resourceType });

      $.ajax({
        url: "/classification_suggestions",
        type: "POST",
        data: $.param(params),
        dataType: "json",
        timeout: 50000,
        success: function(data) {
          CS.renderResponse($form, data);
        },
        error: function() {
          CS.showPanelMessage(panels.tags, panels.tags.data("error"));
          CS.showPanelMessage(panels.sdgs, panels.sdgs.data("error"));
        },
        complete: function() {
          $button.prop("disabled", false);
          $button.removeClass("is-loading");
        }
      });
    },
    showPanelMessage: function($panel, message) {
      if (!$panel.length) {
        return;
      }

      $panel.removeClass("hide");
      CS.resetPanelBody($panel, message);
    },
    resetPanelBody: function($panel, message) {
      var $body = $panel.find(".classification-suggestions-body");

      $panel.removeAttr("aria-labelledby");
      $body.empty();
      $body.append(CS.closeButton($panel));
      $body.append($("<p>").text(message));
    },
    titleId: function($panel) {
      if ($panel.hasClass("classification-suggestions-tags")) {
        return "classification-suggestions-tags-title";
      }

      return "classification-suggestions-sdgs-title";
    },
    renderResponse: function($form, data) {
      var panels = CS.panelsFor($form);
      var errors = data.errors || [];
      var categories = data.categories || [];
      var tags = data.tags || [];
      var sdgs = data.sdgs || [];
      var errorMessage;

      if (errors.length) {
        errorMessage = errors.join(" ");
        CS.showPanelMessage(panels.tags, errorMessage);
        CS.showPanelMessage(panels.sdgs, errorMessage);
        return;
      }

      CS.renderTagsPanel(panels.tags, categories, tags);
      CS.renderSdgsPanel($form, panels.sdgs, sdgs);
      CS.bindListSync($form);
    },
    renderTagsPanel: function($panel, categories, tags) {
      var items = [];

      if (!$panel.length) {
        return;
      }

      categories.forEach(function(name) {
        items.push({ type: "category", value: name, label: name });
      });
      tags.forEach(function(name) {
        items.push({ type: "tag", value: name, label: name });
      });

      CS.fillSuggestionPanel($panel, items);
    },
    renderSdgsPanel: function($form, $panel, sdgs) {
      var items = [];
      var suggestions = CS.sdgSuggestions($form);

      if (!$panel.length) {
        return;
      }

      sdgs.forEach(function(sdg) {
        var code = typeof sdg === "object" && sdg !== null ? sdg.code : sdg;
        var reason = typeof sdg === "object" && sdg !== null ? sdg.reason : null;
        var parts = CS.sdgLabelParts(suggestions, code);

        items.push({
          type: "sdg",
          value: String(code),
          label: parts.label,
          code: parts.code,
          sdgTitle: parts.title,
          reason: reason
        });
      });

      CS.fillSuggestionPanel($panel, items);
    },
    fillSuggestionPanel: function($panel, items) {
      var $body;
      var titleId;
      var $title;

      if (!items.length) {
        CS.showPanelMessage($panel, $panel.data("empty"));
        return;
      }

      titleId = CS.titleId($panel);
      $title = $("<h4>").attr("id", titleId).text($panel.data("title"));
      $body = $panel.find(".classification-suggestions-body");
      $panel.removeClass("hide");
      $panel.attr("aria-labelledby", titleId);
      $body.empty();
      $body.append(CS.closeButton($panel));
      $body.append($title);
      $body.append(CS.suggestionButtons($panel, items));
      $body.append(CS.panelActions($panel));
    },
    suggestionButtons: function($panel, items) {
      var $list = $("<div>").addClass("classification-suggestion-list");
      var template = $panel.find(".classification-suggestion-template").get(0);

      items.forEach(function(item) {
        var $button = $(document.importNode(template.content, true).children);
        var $label = $button.find(".classification-suggestion-label");

        $button.attr("data-suggestion-type", item.type);
        $button.attr("data-value", item.value);
        $button.attr("aria-label", item.label);
        $button.attr("title", item.reason || item.label);

        if (item.type === "sdg" && item.code && item.sdgTitle) {
          $label.empty();
          $label.append(
            $("<strong>").addClass("classification-suggestion-code").text(item.code)
          );
          $label.append(document.createTextNode(" "));
          $label.append(
            $("<span>").addClass("classification-suggestion-text").text(item.sdgTitle)
          );
        } else {
          $label.text(item.label);
        }

        $list.append($button);
      });

      return $list;
    },
    panelActions: function($panel) {
      return $("<div>")
        .addClass("classification-suggestion-actions")
        .append(
          $("<button>")
            .attr("type", "button")
            .addClass("button classification-accept-all")
            .text($panel.data("accept-all"))
        );
    },
    closeButton: function($panel) {
      return $("<button>")
        .attr("type", "button")
        .attr("aria-label", $panel.data("close"))
        .addClass("close-button classification-dismiss")
        .html("&times;");
    },
    dismissPanel: function($panel) {
      if (!$panel.length) {
        return;
      }

      $panel.addClass("hide");
    },
    remainingSuggestions: function($panel) {
      return $panel.find(CS.remainingSelector);
    },
    panelHasSuggestions: function($panel) {
      return $panel.length > 0 && CS.remainingSuggestions($panel).length > 0;
    },
    bindListSync: function($form) {
      var pairs = [
        { selector: ".taggable-fields input.tomselected", panel: ".classification-suggestions-tags" },
        { selector: ".sdg-related-list-selector .input", panel: ".classification-suggestions-sdgs" }
      ];

      pairs.forEach(function(pair) {
        var input = $form.find(pair.selector)[0];
        var control = input && input.tomselect;
        var $panel = $form.find(pair.panel);

        if (!control || !$panel.length) {
          return;
        }

        if (!control.classificationSuggestionsBound) {
          control.classificationSuggestionsBound = true;
          control.on("change", function() {
            CS.syncPanelToControl($panel, control);
          });
        }

        CS.syncPanelToControl($panel, control);
      });
    },
    syncPanelToControl: function($panel, control) {
      var selected;

      if (!$panel.length || !control) {
        return;
      }

      selected = control.items.map(String);

      $panel.find(".classification-suggestion").each(function() {
        var $button = $(this);
        var value = String($button.data("value"));
        var selectedNow = selected.indexOf(value) !== -1;

        $button.toggleClass(CS.appliedClasses, selectedNow);
      });

      if (CS.remainingSuggestions($panel).length > 0) {
        $panel.removeClass("hide");
      } else {
        CS.dismissPanel($panel);
      }
    },
    restorePanelsIfCached: function($tagsPanel, $sdgsPanel) {
      var tagsCached = CS.panelHasSuggestions($tagsPanel);
      var sdgsCached = CS.panelHasSuggestions($sdgsPanel);

      if (!tagsCached && !sdgsCached) {
        return false;
      }

      if (tagsCached) {
        $tagsPanel.removeClass("hide");
      }

      if (sdgsCached) {
        $sdgsPanel.removeClass("hide");
      }

      return true;
    },
    sdgSuggestions: function($form) {
      var raw = $form.find(".sdg-related-list-selector .input").data("suggestions-list");

      if (!raw) {
        return [];
      }

      if (typeof raw === "string") {
        try {
          return JSON.parse(raw);
        } catch (error) {
          return [];
        }
      }

      return raw;
    },
    sdgLabelParts: function(suggestions, code) {
      var match;
      var codeString = String(code);

      match = suggestions.find(function(item) {
        return String(item.value) === codeString;
      });

      if (match && match.title) {
        return {
          code: codeString,
          title: match.title,
          label: codeString + " " + match.title
        };
      }

      if (match && match.display_text) {
        return { code: null, title: null, label: match.display_text };
      }

      return { code: null, title: null, label: codeString };
    },
    applySuggestion: function($button) {
      var type = $button.data("suggestion-type");
      var value = String($button.data("value"));
      var $form = $button.closest("form");

      if ($button.hasClass("is-applied")) {
        return;
      }

      if (type === "category") {
        CS.applyCategory($form, value);
      } else if (type === "tag") {
        CS.applyTag($form, value);
      } else if (type === "sdg") {
        CS.applySdg($form, value);
      }
    },
    applyCategory: function($form, value) {
      var $checkbox = $form.find(".taggable-fields .tags input[type='checkbox']").filter(function() {
        return String($(this).data("list-value")) === value;
      });

      if ($checkbox.length) {
        if (!$checkbox.prop("checked")) {
          $checkbox.prop("checked", true).trigger("change");
        }
        return;
      }

      CS.applyTag($form, value);
    },
    applyTag: function($form, value) {
      CS.addListValue($form, ".taggable-fields input.tomselected", value);
    },
    applySdg: function($form, value) {
      CS.addListValue($form, ".sdg-related-list-selector .input", value);
    },
    addListValue: function($form, selector, value) {
      var input = $form.find(selector)[0];
      var control = input && input.tomselect;

      if (!control) {
        return;
      }

      if (control.items.indexOf(value) === -1) {
        control.createItem(value);
      }
    }
  };
}).call(this);
