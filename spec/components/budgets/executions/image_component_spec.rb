require "rails_helper"

describe Budgets::Executions::ImageComponent do
  let(:component) { Budgets::Executions::ImageComponent.new(investment) }

  context "investment with image" do
    let(:investment) { create(:budget_investment, :with_image) }

    it "shows a milestone image if available" do
      create(:milestone, :with_image, image_title: "Building in progress", milestoneable: investment)

      render_inline component

      expect(page).to have_css "img[alt='Building in progress']"
      expect(page).not_to have_css "img[alt='#{investment.image.title}']"
    end

    it "shows the investment image if no milestone image is available" do
      create(:milestone, :with_image, image_title: "Not related", milestoneable: create(:budget_investment))

      render_inline component

      expect(page).to have_css "img[alt='#{investment.image.title}']"
      expect(page).not_to have_css "img[alt='Not related']"
    end

    it "shows the last milestone's image if the investment has multiple milestones with images associated" do
      create(:milestone, milestoneable: investment)
      create(:milestone, :with_image, image_title: "First image", milestoneable: investment)
      create(:milestone, :with_image, image_title: "Second image", milestoneable: investment)
      create(:milestone, milestoneable: investment)

      render_inline component

      expect(page).to have_css "img[alt='Second image']"
      expect(page).not_to have_css "img[alt='First image']"
      expect(page).not_to have_css "img[alt='#{investment.image.title}']"
    end
  end

  context "investment and milestone without image" do
    let(:investment) { Budget::Investment.new(title: "New and empty") }

    it "shows the default image" do
      render_inline component

      expect(page).to have_css "img[src*='budget_execution_no_image'][alt='New and empty']"
    end

    it "shows a custom default image when available" do
      stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "budget_execution_no_image" => [260, 80] })
      create(:site_customization_image,
             name: "budget_execution_no_image",
             image: fixture_file_upload("logo_header-260x80.png"))

      render_inline component

      expect(page).to have_css "img[src$='logo_header-260x80.png'][alt='New and empty']"
      expect(page).not_to have_css "img[src*='budget_execution_no_image']"
    end
  end
end
