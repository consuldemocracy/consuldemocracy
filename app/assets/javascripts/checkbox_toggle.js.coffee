App.CheckboxToggle =

  initialize: ->
    $('[data-checkbox-toggle]').on 'change', ->
      $this = $(this)
      $target = $($this.data('checkbox-toggle'))
      if $this.is(':checked')
        $target.show()
      else
        $target.hide()


