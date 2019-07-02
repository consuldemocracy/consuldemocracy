(function() {
  "use strict";
  App.LegislationAnnotatable = {
    makeEditableAndHighlight: function(colour) {
      var range, sel;
      sel = window.getSelection();
      if (sel.rangeCount && sel.getRangeAt) {
        range = sel.getRangeAt(0);
      }
      document.designMode = "on";
      if (range) {
        sel.removeAllRanges();
        sel.addRange(range);
      }
      if (!document.execCommand("HiliteColor", false, colour)) {
        document.execCommand("BackColor", false, colour);
      }
      document.designMode = "off";
    },
    highlight: function(colour) {
      try {
        if (!document.execCommand("BackColor", false, colour)) {
          App.LegislationAnnotatable.makeEditableAndHighlight(colour);
        }
      } catch (error) {
        App.LegislationAnnotatable.makeEditableAndHighlight(colour);
      }
    },
    remove_highlight: function() {
      $("[data-legislation-draft-version-id] span[style]").replaceWith(function() {
        return $(this).contents();
      });
    },
    renderAnnotationComments: function(event) {
      if (event.offset) {
        $("#comments-box").css({
          top: event.offset - $(".calc-comments").offset().top
        });
      }
      if (App.LegislationAnnotatable.isMobile()) {
        return;
      }
      $.ajax({
        method: "GET",
        url: event.annotation_url + "/annotations/" + event.annotation_id + "/comments",
        dataType: "script"
      });
    },
    onClick: function(event) {
      var annotation_id, annotation_url, parents, parents_ids, target;
      event.preventDefault();
      event.stopPropagation();
      if (App.LegislationAnnotatable.isMobile()) {
        annotation_url = $(event.target).closest(".legislation-annotatable").data("legislation-annotatable-base-url");
        window.location.href = annotation_url + "/annotations/" + ($(this).data("annotation-id"));
        return;
      }
      $("[data-annotation-id]").removeClass("current-annotation");
      target = $(this);
      parents = target.parents(".annotator-hl");
      parents_ids = parents.map(function(_, elem) {
        return $(elem).data("annotation-id");
      });
      annotation_id = target.data("annotation-id");
      $("[data-annotation-id='" + annotation_id + "']").addClass("current-annotation");
      $("#comments-box").html("");
      App.LegislationAllegations.show_comments();
      $("#comments-box").show();
      $.event.trigger({
        type: "renderLegislationAnnotation",
        annotation_id: target.data("annotation-id"),
        annotation_url: target.closest(".legislation-annotatable").data("legislation-annotatable-base-url"),
        offset: target.offset()["top"]
      });
      parents_ids.each(function(i, pid) {
        $.event.trigger({
          type: "renderLegislationAnnotation",
          annotation_id: pid,
          annotation_url: target.closest(".legislation-annotatable").data("legislation-annotatable-base-url")
        });
      });
    },
    isMobile: function() {
      return window.innerWidth <= 652;
    },
    viewerExtension: function(viewer) {
      return viewer._onHighlightMouseover = function() {};
    },
    customShow: function(position) {
      var annotation_url;
      $(this.element).html("");
      // Clean comments section and open it
      $("#comments-box").html("");
      App.LegislationAllegations.show_comments();
      $("#comments-box").show();
      annotation_url = $("[data-legislation-annotatable-base-url]").data("legislation-annotatable-base-url");
      $.ajax({
        method: "GET",
        url: annotation_url + "/annotations/new",
        dataType: "script"
      }).done((function() {
        $("#new_legislation_annotation #legislation_annotation_quote").val(this.annotation.quote);
        $("#new_legislation_annotation #legislation_annotation_ranges").val(JSON.stringify(this.annotation.ranges));
        $("#comments-box").css({
          top: position.top - $(".calc-comments").offset().top
        });
        if ($("[data-legislation-open-phase]").data("legislation-open-phase") !== false) {
          App.LegislationAnnotatable.highlight("#7fff9a");
          $("#comments-box textarea").focus();
          $("#new_legislation_annotation").on("ajax:complete", function(e, data) {
            App.LegislationAnnotatable.app.destroy();
            if (data.status === 200) {
              App.LegislationAnnotatable.remove_highlight();
              $("#comments-box").html("").hide();
              $.ajax({
                method: "GET",
                url: annotation_url + "/annotations/" + data.responseJSON.id + "/comments",
                dataType: "script"
              });
            } else {
              $(e.target).find("label").addClass("error");
              $("<small class='error'>" + data.responseJSON[0] + "</small>").insertAfter($(e.target).find("textarea"));
            }
          });
        }
      }).bind(this));
    },
    editorExtension: function(editor) {
      return editor.show = App.LegislationAnnotatable.customShow;
    },
    scrollToAnchor: function() {
      return {
        annotationsLoaded: function() {
          var anchor, ann_id, checkExist;
          anchor = $(location).attr("hash");
          if (anchor && anchor.startsWith("#annotation")) {
            ann_id = anchor.split("-").slice(-1);
            return checkExist = setInterval((function() {
              var el;
              if ($("span[data-annotation-id='" + ann_id + "']").length) {
                el = $("span[data-annotation-id='" + ann_id + "']");
                el.addClass("current-annotation");
                $("#comments-box").html("");
                App.LegislationAllegations.show_comments();
                $("html,body").animate({
                  scrollTop: el.offset().top
                });
                $.event.trigger({
                  type: "renderLegislationAnnotation",
                  annotation_id: ann_id,
                  annotation_url: el.closest(".legislation-annotatable").data("legislation-annotatable-base-url"),
                  offset: el.offset()["top"]
                });
                clearInterval(checkExist);
              }
            }), 100);
          }
        }
      };
    },
    propotionalWeight: function(v, max) {
      return Math.floor(v * 5 / (max + 1)) + 1;
    },
    addWeightClasses: function() {
      return {
        annotationsLoaded: function(annotations) {
          var checkExist, last_annotation, max_weight, weights;
          if (annotations.length === 0) {
            return;
          }
          weights = annotations.map(function(ann) {
            return ann.weight;
          });
          max_weight = Math.max.apply(null, weights);
          last_annotation = annotations[annotations.length - 1];
          return checkExist = setInterval((function() {
            if ($("span[data-annotation-id='" + last_annotation.id + "']").length) {
              annotations.forEach(function(annotation) {
                var ann_weight, el;
                ann_weight = App.LegislationAnnotatable.propotionalWeight(annotation.weight, max_weight);
                el = $("span[data-annotation-id='" + annotation.id + "']");
                el.addClass("weight-" + ann_weight);
              });
              clearInterval(checkExist);
            }
          }), 100);
        }
      };
    },
    initialize: function() {
      var current_user_id;
      $(document).off("renderLegislationAnnotation").on("renderLegislationAnnotation", App.LegislationAnnotatable.renderAnnotationComments);
      $(document).off("click", "[data-annotation-id]").on("click", "[data-annotation-id]", App.LegislationAnnotatable.onClick);
      $(document).off("click", "[data-cancel-annotation]").on("click", "[data-cancel-annotation]", function(e) {
        e.preventDefault();
        $("#comments-box").html("");
        $("#comments-box").hide();
        App.LegislationAnnotatable.remove_highlight();
      });
      current_user_id = $("html").data("current-user-id");
      $(".legislation-annotatable").each(function() {
        var ann_id, base_url;
        ann_id = $(this).data("legislation-draft-version-id");
        base_url = $(this).data("legislation-annotatable-base-url");
        App.LegislationAnnotatable.app = new annotator.App().include(function() {
          return {
            beforeAnnotationCreated: function(ann) {
              ann["legislation_draft_version_id"] = ann_id;
              ann.permissions = ann.permissions || {};
              ann.permissions.admin = [];
            }
          };
        }).include(annotator.ui.main, {
          element: this,
          viewerExtensions: [App.LegislationAnnotatable.viewerExtension],
          editorExtensions: [App.LegislationAnnotatable.editorExtension]
        }).include(App.LegislationAnnotatable.scrollToAnchor).include(App.LegislationAnnotatable.addWeightClasses).include(annotator.storage.http, {
          prefix: base_url,
          urls: {
            search: "/annotations/search"
          }
        });
        App.LegislationAnnotatable.app.start().then(function() {
          App.LegislationAnnotatable.app.ident.identity = current_user_id;
          App.LegislationAnnotatable.app.annotations.load({
            legislation_draft_version_id: ann_id
          });
        });
      });
    }
  };
}).call(this);
