require "rails_helper"

describe Debates::NewComponent do
  let(:debate) { build(:debate) }

  describe "header" do
    it "contains a link to open the help page in a new window" do
      render_inline Debates::NewComponent.new(debate)

      page.find("header") do |header|
        expect(header).to have_css "a[target=_blank]", exact_text: "How do debates work?"
      end
    end
  end
end
