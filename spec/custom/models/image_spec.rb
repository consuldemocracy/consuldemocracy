require 'rails_helper'

# TODO i18n : broken because of test locale change
xdescribe Image do
  it_behaves_like "image validations", "budget_investment_image"
  it_behaves_like "image validations", "proposal_image"

end
