require "rails_helper"

describe "Cache flow" do

  describe "Tag destroy" do
    it "invalidates Debate cache keys" do
      debate = create(:debate, tag_list: "Good, Bad")
      tag = ActsAsTaggableOn::Tag.find_by(name: "Bad")

      expect{tag.destroy}.to change {debate.reload.cache_key}
    end
  end

end
