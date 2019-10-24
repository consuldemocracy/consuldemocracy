shared_examples "sanitizable" do
  let(:sanitizable) { build(model_name(described_class)) }

  describe "#tag_list" do
    before do
      unless described_class.included_modules.include?(Taggable)
        skip "#{described_class} does not have a tag list"
      end
    end

    it "sanitizes the tag list" do
      sanitizable.tag_list = "user_id=1"

      sanitizable.valid?

      expect(sanitizable.tag_list).to eq(["user_id1"])
    end
  end
end
