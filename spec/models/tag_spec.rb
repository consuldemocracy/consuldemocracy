require 'rails_helper'

describe 'Tag' do

  describe "public_for_api scope" do
    it "returns tags whose kind is NULL" do
      tag = create(:tag, kind: nil)

      expect(Tag.public_for_api).to include(tag)
    end

    it "returns tags whose kind is 'category'" do
      tag = create(:tag, kind: 'category')

      expect(Tag.public_for_api).to include(tag)
    end

    it "blocks other kinds of tags" do
      tag = create(:tag, kind: 'foo')

      expect(Tag.public_for_api).not_to include(tag)
    end
  end
end
