require 'rails_helper'

describe CategoryImporter do
  describe ".import" do
    it "should create categories and subcategories from an arbitrary file" do
      file = Tempfile.new('test')
      file.write({ categories: categories }.to_json)
    end
  end
end
