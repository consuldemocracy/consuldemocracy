(function() {
  "use strict";
  App.TreeNavigator = {
    setNodes: function(nodes) {
      nodes.children("ul").each(function() {
        var link;
        link = $(this).prev("a");
        $('<span class="open"></span>').insertBefore(link);
        App.TreeNavigator.setNodes($(this).children());
      });
    },
    initialize: function() {
      var anchor, elem, ul;
      elem = $("[data-tree-navigator]");
      if (elem.length === 0) {
        return;
      }
      ul = elem.find("ul:eq(0)");
      if (ul.length && ul.children().length) {
        App.TreeNavigator.setNodes(ul.children());
      }
      $("[data-tree-navigator] span").on({
        click: function() {
          if ($(this).hasClass("open")) {
            $(this).removeClass("open").addClass("closed");
            $(this).siblings("ul").hide();
          } else if ($(this).hasClass("closed")) {
            $(this).removeClass("closed").addClass("open");
            $(this).siblings("ul").show();
          }
        }
      });
      anchor = $(location).attr("hash");
      if (anchor) {
        elem.find("a[href='" + anchor + "']").parents("ul").each(function() {
          $(this).show();
          $(this).siblings("span").removeClass("closed").addClass("open");
        });
      }
    }
  };
}).call(this);
