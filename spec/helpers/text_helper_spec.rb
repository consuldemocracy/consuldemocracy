require "rails_helper"

describe TextHelper do

  describe "#first_paragraph" do
    it "returns the first paragraph of a text" do
      text = "\n\nThis is the first paragraph\n\nThis is the second paragraph\n"
      expect(first_paragraph(text)).to eq("This is the first paragraph")
    end

    it "returns blank if the text is blank" do
      expect(first_paragraph("")).to eq("")
      expect(first_paragraph(nil)).to eq("")
    end
  end

end
