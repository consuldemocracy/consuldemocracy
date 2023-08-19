require "rails_helper"

describe Widget::Feeds::ProcessComponent do
  let(:process) { create(:legislation_process, sdg_goals: [SDG::Goal[1]]) }
  let(:component) { Widget::Feeds::ProcessComponent.new(process) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.legislation"] = true
  end

  it "renders a card with link" do
    render_inline component

    expect(page).to have_link href: "/legislation/processes/#{process.to_param}"
  end

  it "renders a plain tag list" do
    render_inline component

    expect(page).to have_css("img[alt='1. No Poverty']")
  end

  describe "image" do
    it "shows the default image" do
      render_inline component

      expect(page).to have_css "img[src*='welcome_process']"
    end

    it "shows a custom default image when available" do
      stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "welcome_process" => [260, 80] })
      create(:site_customization_image,
             name: "welcome_process",
             image: fixture_file_upload("logo_header-260x80.png"))

      render_inline component

      expect(page).to have_css "img[src$='logo_header-260x80.png']"
      expect(page).not_to have_css "img[src*='welcome_process']"
    end
  end
end
