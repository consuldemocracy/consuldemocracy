require "rails_helper"

describe Image do

  it_behaves_like "image validations", "budget_investment_image"
  it_behaves_like "image validations", "proposal_image"

end
