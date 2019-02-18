require "rails_helper"

describe WYSIWYGSanitizer do

  subject { described_class.new }

  describe "#sanitize" do

    it "returns an html_safe string" do
      expect(subject.sanitize("hello")).to be_html_safe
    end

    it "allows basic html formatting" do
      html = "<p>This is <strong>a paragraph</strong></p>"
      expect(subject.sanitize(html)).to eq(html)
    end

    it "allows links" do
      html = '<p><a href="/">Home</a></p>'
      expect(subject.sanitize(html)).to eq(html)
    end

    it "allows headings" do
      html = "<h2>Objectives</h2><p>Fix flaky specs</p><h3>Explain why the test is flaky</h3>"
      expect(subject.sanitize(html)).to eq(html)
    end

    it "filters out dangerous tags" do
      html = "<p>This is <script>alert('dangerous');</script></p>"
      expect(subject.sanitize(html)).to eq("<p>This is alert('dangerous');</p>")
    end

    it "filters images" do
      html = "Dangerous<img src='/smile.png' alt='Smile' style='width: 10px';> image"
      expect(subject.sanitize(html)).to eq("Dangerous image")
    end
  end

end
