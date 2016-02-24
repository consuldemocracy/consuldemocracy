App.AdminValuatorsForms =

  initialize: ->
    $('#spending_proposal_administrator_id').unbind('change').on('change', ->
      $('#administrator_assignment_form').submit()
      false
      )

    $('#assign-valuators-link').unbind('click').on('click', ->
      $('#valuators-assign-list').toggle("down")
      false
    )

    $('.js-assign-valuators-check').unbind('change').on('change', ->
      $('#valuators_assignment_form').submit()
      false
      )
