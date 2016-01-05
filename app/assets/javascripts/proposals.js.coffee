App.Proposals =

  initialize: ->
    this.proposalsForm = $('.new_proposal, .edit_proposal')
    this.proposalDistrictSelect = this.proposalsForm.find('select[name="proposal[district]"]')
    this.proposalScopeRadio = this.proposalsForm.find('input[name="proposal[scope]"]')
    this.proposalScopeRadio.on('change', (event) => this.checkDistrictSelectVisibility(event.target.value))

    currentScope = this.proposalScopeRadio.filter((index, radio) => $(radio).attr('checked'))

    if currentScope
      this.checkDistrictSelectVisibility(currentScope[0].value)

  checkDistrictSelectVisibility: (scope) ->
    this.proposalDistrictSelect.attr('disabled', scope == 'city')

