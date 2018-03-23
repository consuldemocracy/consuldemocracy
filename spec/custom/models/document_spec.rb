require 'rails_helper'

# TODO i18n : broken because of test locale change
xdescribe Document do
  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

end
