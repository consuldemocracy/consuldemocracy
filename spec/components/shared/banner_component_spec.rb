require "rails_helper"

describe Shared::BannerComponent, type: :component do
  it "renders given a banner" do
    render_inline Shared::BannerComponent.new(create(:banner, title: "Vote now!"))

    expect(page.find(".banner")).to have_content "Vote now!"
  end

  it "does not render anything given nil" do
    render_inline Shared::BannerComponent.new(nil)

    expect(page).not_to have_css ".banner"
  end
end
