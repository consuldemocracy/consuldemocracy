require "rails_helper"

describe "Commenting proposals" do
  it_behaves_like "flaggable", :proposal_comment
end
