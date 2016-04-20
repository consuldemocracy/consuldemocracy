App.ValuationSpendingProposalForm =

  showFeasibleFields: ->
    $('#valuation_spending_proposal_edit_form #not_feasible_fields').hide('down')
    $('#valuation_spending_proposal_edit_form #feasible_fields').show()

  showNotFeasibleFields: ->
    $('#valuation_spending_proposal_edit_form #feasible_fields').hide('down')
    $('#valuation_spending_proposal_edit_form #not_feasible_fields').show()

  showAllFields: ->
    $('#valuation_spending_proposal_edit_form #feasible_fields').show('down')
    $('#valuation_spending_proposal_edit_form #not_feasible_fields').show('down')

  showFeasibilityFields: ->
    feasible = $("#valuation_spending_proposal_edit_form input[type=radio][name='spending_proposal[feasible]']:checked").val()
    if feasible == 'true'
      App.ValuationSpendingProposalForm.showFeasibleFields()
    else if feasible == 'false'
      App.ValuationSpendingProposalForm.showNotFeasibleFields()


  showFeasibilityFieldsOnChange: ->
    $("#valuation_spending_proposal_edit_form input[type=radio][name='spending_proposal[feasible]']").change ->
      App.ValuationSpendingProposalForm.showAllFields()
      App.ValuationSpendingProposalForm.showFeasibilityFields()


  initialize: ->
    App.ValuationSpendingProposalForm.showFeasibilityFields()
    App.ValuationSpendingProposalForm.showFeasibilityFieldsOnChange()
    false