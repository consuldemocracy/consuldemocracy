App.SendAdminNotificationAlert =
  initialize: ->
    $('#js-send-admin_notification-alert').on 'click', ->
        confirm(this.dataset.alert);
