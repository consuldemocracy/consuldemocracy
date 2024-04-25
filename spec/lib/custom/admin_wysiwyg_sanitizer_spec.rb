require "rails_helper"

describe AdminWYSIWYGSanitizer do
  let(:sanitizer) { AdminWYSIWYGSanitizer.new }

  describe "#sanitize" do
    it "allows iframe" do
      html = "<iframe width=\"560\" height=\"315\" src=\"https://youtube.com/embed/test\"></iframe>"
      expect(sanitizer.sanitize(html)).to eq(html)
    end
  end
end
