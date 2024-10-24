require "rails_helper"

describe Budgets::Executions::ImageComponent do
  context "investment and milestone without image" do
    let(:component) { Budgets::Executions::ImageComponent.new(Budget::Investment.new) }

    it "shows the default image" do
      render_inline component

      expect(page).to have_css "img[src*='budget_execution_no_image']"
    end

    it "shows a custom default image when available" do
      stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "budget_execution_no_image" => [260, 80] })
      create(:site_customization_image,
             name: "budget_execution_no_image",
             image: fixture_file_upload("logo_header-260x80.png"))

      render_inline component

      expect(page).to have_css "img[src$='logo_header-260x80.png']"
      expect(page).not_to have_css "img[src*='budget_execution_no_image']"
    end
  end
end
