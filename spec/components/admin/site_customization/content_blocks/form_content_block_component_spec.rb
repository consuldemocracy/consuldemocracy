require "rails_helper"

describe Admin::SiteCustomization::ContentBlocks::FormContentBlockComponent do
  describe "locale selector" do
    let(:content_block) { create(:site_customization_content_block, locale: "de") }
    let(:component) do
      Admin::SiteCustomization::ContentBlocks::FormContentBlockComponent.new(content_block)
    end

    it "only includes enabled settings" do
      Setting["locales.default"] = "de"
      Setting["locales.enabled"] = "de fr"

      render_inline component

      expect(page).to have_select "locale", options: ["de", "fr"]
    end
  end
end
