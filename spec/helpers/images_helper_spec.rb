require "rails_helper"

describe ImagesHelper do
  describe "#attached_background_css" do
    it "adds quotes around the path" do
      expect(attached_background_css("myurl")).to eq "background-image: url('myurl');"
    end

    it "escapes quotes inside the path" do
      expect(attached_background_css("url_'quotes'")).to eq "background-image: url('url_\\'quotes\\'');"
    end
  end
end
