App.SendNewsletterAlert =
  initialize: ->
    $('#js-send-newsletter-alert').on 'click', ->
        confirm(this.dataset.alert);
