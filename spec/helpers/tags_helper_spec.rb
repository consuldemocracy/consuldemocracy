require 'rails_helper'

describe TagsHelper do

  describe "#display_tag_list" do
    it "displays all tags for a resource" do
      proposal = create(:proposal, tag_list: ["open-plenary", "johnson-and-smithers"])
      expect(display_tag_list(proposal)).to eq("open-plenary, johnson-and-smithers")
    end

    it "displays a comma if there is only one tag" do
      proposal = create(:proposal, tag_list: "open-plenary")
      expect(display_tag_list(proposal)).to eq("open-plenary,")
    end
  end
end