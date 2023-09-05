require "rails_helper"

describe AdminWYSIWYGSanitizer do
  let(:sanitizer) { AdminWYSIWYGSanitizer.new }

  describe "#sanitize" do
    it "allows br" do
      html = "<p><strong>This is a text</strong><br>With a break line</p>"
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows iframe" do
      html = "<iframe width=\"560\" height=\"315\" src=\"https://youtube.com/embed/test\"></iframe>"
      expect(sanitizer.sanitize(html)).to eq(html)
    end
  end
end
