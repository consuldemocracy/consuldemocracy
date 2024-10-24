require "rails_helper"

describe Tagging do
  describe ".public_for_api" do
    it "returns taggings for debates and proposals" do
      create(:tag, name: "Health", kind: nil)
      debate = create(:debate, tag_list: "Health")
      proposal = create(:proposal, tag_list: "Health")

      expect(Tagging.public_for_api.map(&:taggable)).to match_array [debate, proposal]
    end

    it "does not return taggings for other tag kinds" do
      create(:tag, name: "Health", kind: "custom")
      create(:debate, tag_list: "Health")
      create(:proposal, tag_list: "Health")

      expect(Tagging.public_for_api.map(&:taggable)).to be_empty
    end
  end
end
