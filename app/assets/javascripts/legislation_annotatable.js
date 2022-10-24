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
    loadAnnotationComments: function(annotation_url, annotation_id) {
      $.ajax({
        method: "GET",
        url: annotation_url + "/annotations/" + annotation_id + "/comments",
        dataType: "script"
      });
    },
    renderAnnotationComments: function(event) {
      if (event.offset) {
        var default_top = $(".calc-comments").offset().top + $(".calc-comments .draft-panel").outerHeight();

        $("#comments-box").css({
          top: event.offset - default_top
        });
      }
      if (App.LegislationAnnotatable.isMobile()) {
        return;
      }
      App.LegislationAnnotatable.loadAnnotationComments(event.annotation_url, event.annotation_id);
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
      $("body").trigger({
        type: "renderLegislationAnnotation",
        annotation_id: target.data("annotation-id"),
        annotation_url: target.closest(".legislation-annotatable").data("legislation-annotatable-base-url"),
        offset: target.offset().top
      });
      parents_ids.each(function(i, pid) {
        $("body").trigger({
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
          $("#comments-box textarea").trigger("focus");
          $("#new_legislation_annotation").on("ajax:complete", function(e, data) {
            if (data.status === 200) {
              App.LegislationAnnotatable.remove_highlight();
              App.LegislationAnnotatable.app.annotations.runHook("annotationCreated", [data.responseJSON]);
              $("#comments-box").html("").hide();
              App.LegislationAnnotatable.loadAnnotationComments(annotation_url, data.responseJSON.id);
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
                $("body").trigger({
                  type: "renderLegislationAnnotation",
                  annotation_id: ann_id,
                  annotation_url: el.closest(".legislation-annotatable").data("legislation-annotatable-base-url"),
                  offset: el.offset().top
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
    initCommentFormToggler: function() {
      $("body").on("click", ".comment-box a.publish-comment", function(e) {
        e.preventDefault();
        var annotation_id = $(this).closest(".comment-box").data("id");
        $("a.publish-comment").hide();
        $("#js-comment-form-annotation-" + annotation_id).toggle();
        $("#js-comment-form-annotation-" + annotation_id + " textarea").trigger("focus");
      });
    },
    initialize: function() {
      var current_user_id;
      $("body").on("renderLegislationAnnotation", App.LegislationAnnotatable.renderAnnotationComments);
      $("body").on("click", "[data-annotation-id]", App.LegislationAnnotatable.onClick);
      $("body").on("click", "[data-cancel-annotation]", function(e) {
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
              ann.legislation_draft_version_id = ann_id;
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

      App.LegislationAnnotatable.initCommentFormToggler();
    },
    destroy: function() {
      if ($(".legislation-annotatable").length > 0) {
        App.LegislationAnnotatable.app.destroy();
      }
    }
  };
}).call(this);
