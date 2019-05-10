require "rails_helper"

describe TagSanitizer do

  subject { described_class.new }

  describe "#sanitize_tag" do
    it "allows regular text, even spaces" do
      expect(subject.sanitize_tag("hello there")).to eq("hello there")
    end

    it "filters out dangerous strings" do
      expect(subject.sanitize_tag("user_id=1")).to eq("user_id1")
    end

    it "sets up a max length for each tag" do
      long_tag = "1" * (described_class.tag_max_length + 100)

      expect(subject.sanitize_tag(long_tag).size).to eq(described_class.tag_max_length)
    end
  end

  describe "#sanitize_tag_list" do
    it "returns a new tag list with sanitized tags" do
      expect(subject.sanitize_tag_list(%w{x=1 y?z})).to eq(%w(x1 yz))
    end
  end

end
