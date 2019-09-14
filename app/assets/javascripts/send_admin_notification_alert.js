(function() {
  "use strict";
  App.SendAdminNotificationAlert = {
    initialize: function() {
      $("#js-send-admin_notification-alert").on("click", function() {
        return confirm(this.dataset.alert);
      });
    }
  };
}).call(this);
