shared_examples "sanitizable" do
  let(:sanitizable)        { build(model_name(described_class)) }

  it "is sanitized" do
    sanitizable.description = "<script>alert('danger');</script>"

    sanitizable.valid?

    expect(sanitizable.description).to eq("alert('danger');")
  end

  it "is html_safe" do
    sanitizable.description = "<script>alert('danger');</script>"

    sanitizable.valid?

    expect(sanitizable.description).to be_html_safe
  end

  it "is sanitized using globalize accessors" do
    sanitizable.description_en = "<script>alert('danger');</script>"

    sanitizable.valid?

    expect(sanitizable.description_en).to eq("alert('danger');")
  end

  it "is html_safe using globalize accessors" do
    sanitizable.description_en = "<script>alert('danger');</script>"

    sanitizable.valid?

    expect(sanitizable.description_en).to be_html_safe
  end

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
