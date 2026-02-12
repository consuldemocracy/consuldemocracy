require "rails_helper"

describe Moderation::MenuComponent do
  describe "aria-current attribute" do
    it "is used on the proposals link when visiting proposals", controller: Moderation::ProposalsController do
      render_inline Moderation::MenuComponent.new

      expect(page).to have_css "[aria-current]", count: 1
      expect(page).to have_css "[aria-current]", exact_text: "Proposals"
    end

    it "is used on the legislation proposals link when visiting legislation proposals",
       controller: Moderation::Legislation::ProposalsController do
      render_inline Moderation::MenuComponent.new

      expect(page).to have_css "[aria-current]", count: 1
      expect(page).to have_css "[aria-current]", exact_text: "Legislation proposals"
    end
  end
end
