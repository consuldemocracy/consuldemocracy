require "rails_helper"

describe Document do

  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

end
