(function() {
  "use strict";

  App.ClassificationSuggestions = {
    panelSelector: ".classification-suggestions-tags, .classification-suggestions-sdgs",
    initialize: function() {
      $("body").on("click", ".suggest-classification", function() {
        App.ClassificationSuggestions.requestSuggestions($(this));
      });

      $("body").on("click", ".classification-suggestion", function() {
        App.ClassificationSuggestions.applySuggestion($(this));
      });

      $("body").on("click", ".classification-accept-all", function() {
        var $panel = $(this).closest(App.ClassificationSuggestions.panelSelector);

        $panel.find(".classification-suggestion").each(function() {
          App.ClassificationSuggestions.applySuggestion($(this));
        });
      });

      $("body").on("click", ".classification-dismiss", function() {
        var $panel = $(this).closest(App.ClassificationSuggestions.panelSelector);

        App.ClassificationSuggestions.dismissPanel($panel);
      });
    },
    requestSuggestions: function($button) {
      var $form = $button.closest("form");
      var resourceType = $button.data("resource-type");
      var $tagsPanel = $form.find(".classification-suggestions-tags");
      var $sdgsPanel = $form.find(".classification-suggestions-sdgs");
      var params;

      if (App.ClassificationSuggestions.restorePanelsIfCached($tagsPanel, $sdgsPanel)) {
        return;
      }

      $button.prop("disabled", true);
      $button.addClass("is-loading");
      App.ClassificationSuggestions.showLoading($tagsPanel);
      App.ClassificationSuggestions.showLoading($sdgsPanel);

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
          App.ClassificationSuggestions.renderResponse($form, data);
        },
        error: function() {
          App.ClassificationSuggestions.showError($tagsPanel);
          App.ClassificationSuggestions.showError($sdgsPanel);
        },
        complete: function() {
          $button.prop("disabled", false);
          $button.removeClass("is-loading");
        }
      });
    },
    showLoading: function($panel) {
      if (!$panel.length) {
        return;
      }

      $panel.removeClass("hide");
      App.ClassificationSuggestions.resetPanelBody($panel, $panel.data("loading"));
    },
    showError: function($panel, message) {
      if (!$panel.length) {
        return;
      }

      $panel.removeClass("hide");
      App.ClassificationSuggestions.resetPanelBody(
        $panel,
        message || $panel.data("error")
      );
    },
    showEmpty: function($panel) {
      if (!$panel.length) {
        return;
      }

      $panel.removeClass("hide");
      App.ClassificationSuggestions.resetPanelBody($panel, $panel.data("empty"));
    },
    resetPanelBody: function($panel, message) {
      var $body = $panel.find(".classification-suggestions-body");

      $panel.removeAttr("aria-labelledby");
      $body.empty();
      $body.append(App.ClassificationSuggestions.closeButton($panel));
      $body.append($("<p>").text(message));
    },
    titleId: function($panel) {
      if ($panel.hasClass("classification-suggestions-tags")) {
        return "classification-suggestions-tags-title";
      }

      return "classification-suggestions-sdgs-title";
    },
    renderResponse: function($form, data) {
      var $tagsPanel = $form.find(".classification-suggestions-tags");
      var $sdgsPanel = $form.find(".classification-suggestions-sdgs");
      var errors = data.errors || [];
      var categories = data.categories || [];
      var tags = data.tags || [];
      var sdgs = data.sdgs || [];
      var errorMessage;

      if (errors.length) {
        errorMessage = errors.join(" ");
        App.ClassificationSuggestions.showError($tagsPanel, errorMessage);
        App.ClassificationSuggestions.showError($sdgsPanel, errorMessage);
        return;
      }

      App.ClassificationSuggestions.renderTagsPanel($tagsPanel, categories, tags);
      App.ClassificationSuggestions.renderSdgsPanel($form, $sdgsPanel, sdgs);
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

      App.ClassificationSuggestions.fillSuggestionPanel($panel, items);
    },
    renderSdgsPanel: function($form, $panel, sdgs) {
      var items = [];
      var suggestions = App.ClassificationSuggestions.sdgSuggestions($form);

      if (!$panel.length) {
        return;
      }

      sdgs.forEach(function(sdg) {
        var code = typeof sdg === "object" && sdg !== null ? sdg.code : sdg;
        var reason = typeof sdg === "object" && sdg !== null ? sdg.reason : null;
        var parts = App.ClassificationSuggestions.sdgLabelParts(suggestions, code);

        items.push({
          type: "sdg",
          value: String(code),
          label: parts.label,
          code: parts.code,
          sdgTitle: parts.title,
          reason: reason
        });
      });

      App.ClassificationSuggestions.fillSuggestionPanel($panel, items);
    },
    fillSuggestionPanel: function($panel, items) {
      var $body;
      var titleId;
      var $title;

      if (!items.length) {
        App.ClassificationSuggestions.showEmpty($panel);
        return;
      }

      titleId = App.ClassificationSuggestions.titleId($panel);
      $title = $("<h4>").attr("id", titleId).text($panel.data("title"));
      $body = $panel.find(".classification-suggestions-body");
      $panel.removeClass("hide");
      $panel.attr("aria-labelledby", titleId);
      $body.empty();
      $body.append(App.ClassificationSuggestions.closeButton($panel));
      $body.append($title);
      $body.append(App.ClassificationSuggestions.suggestionButtons($panel, items));
      $body.append(App.ClassificationSuggestions.panelActions($panel));
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
    panelHasSuggestions: function($panel) {
      return $panel.length > 0 &&
        $panel.find(".classification-suggestion").length > 0;
    },
    restorePanelsIfCached: function($tagsPanel, $sdgsPanel) {
      var tagsCached = App.ClassificationSuggestions.panelHasSuggestions($tagsPanel);
      var sdgsCached = App.ClassificationSuggestions.panelHasSuggestions($sdgsPanel);

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
      var $panel = $button.closest(App.ClassificationSuggestions.panelSelector);

      if (type === "category") {
        App.ClassificationSuggestions.applyCategory($form, value);
      } else if (type === "tag") {
        App.ClassificationSuggestions.applyTag($form, value);
      } else if (type === "sdg") {
        App.ClassificationSuggestions.applySdg($form, value);
      }

      $button.remove();
      App.ClassificationSuggestions.afterSuggestionRemoved($panel);
    },
    applyCategory: function($form, value) {
      var $checkbox = $form.find(".js-tag-category").filter(function() {
        return String($(this).data("list-value")) === value;
      });

      if ($checkbox.length) {
        if (!$checkbox.prop("checked")) {
          $checkbox.prop("checked", true).trigger("change");
        }
        return;
      }

      App.ClassificationSuggestions.applyTag($form, value);
    },
    applyTag: function($form, value) {
      App.ClassificationSuggestions.addListValue($form, "input.js-tag-list", value);
    },
    applySdg: function($form, value) {
      App.ClassificationSuggestions.addListValue(
        $form,
        ".sdg-related-list-selector .input",
        value
      );
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
    },
    afterSuggestionRemoved: function($panel) {
      if (!$panel.length) {
        return;
      }

      if ($panel.find(".classification-suggestion").length === 0) {
        App.ClassificationSuggestions.dismissPanel($panel);
      }
    }
  };
}).call(this);
