App.LocationChanger =

  initialize: ->
    $('.js-location-changer').on 'change', ->
      window.location.assign($(this).val())



