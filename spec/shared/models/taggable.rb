shared_examples "taggable" do
  let(:sanitizable) { build(model_name(described_class)) }

  describe "#tag_list" do
    it "sanitizes the tag list" do
      sanitizable.tag_list = "user_id=1"

      sanitizable.valid?

      expect(sanitizable.tag_list).to eq(["user_id1"])
    end

    it "keeps tag names that contain commas" do
      sanitizable.tag_list = '"Culture, Leisure and Tourism"'

      sanitizable.valid?

      expect(sanitizable.tag_list).to eq(["Culture, Leisure and Tourism"])
    end

    it "keeps comma-containing tags alongside other tags" do
      sanitizable.tag_list = '"Culture, Leisure and Tourism", Local Issues'

      sanitizable.valid?

      expect(sanitizable.tag_list).to eq(["Culture, Leisure and Tourism", "Local Issues"])
    end
  end
end
