(function() {
  "use strict";
  App.AdminTenantsForm = {
    initialize: function() {
      var form = $(".admin .tenant-form");
      var inputs = $("input[name$='[schema_type]']", form);
      var label = $("label[for$='schema']", form);

      inputs.on("change", function() {
        label.text(label.data("schema-type-" + $(this).val()));
      });

      inputs.each(function() {
        if ($(this).is(":checked")) {
          $(this).trigger("change");
        }
      });
    }
  };
}).call(this);
