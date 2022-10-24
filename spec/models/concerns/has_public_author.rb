require "spec_helper"

shared_examples_for "has_public_author" do
  let(:model) { described_class }

  describe "public_author" do
    it "returns author if author's activity is public" do
      author = create(:user, public_activity: true)
      authored_element = create(model.to_s.underscore.to_sym, author: author)

      expect(authored_element.public_author).to eq(author)
    end

    it "returns nil if author's activity is private" do
      author = create(:user, public_activity: false)
      authored_element = create(model.to_s.underscore.to_sym, author: author)

      expect(authored_element.public_author).to be_nil
    end
  end
end
