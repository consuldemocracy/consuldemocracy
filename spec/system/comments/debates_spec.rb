require "rails_helper"

describe "Commenting debates" do
  it_behaves_like "flaggable", :debate_comment
end
