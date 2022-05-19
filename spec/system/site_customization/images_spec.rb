require "rails_helper"

describe "Site customization images" do
  scenario "Custom favicon" do
    create(:site_customization_image, name: "favicon", image: fixture_file_upload("favicon_custom.ico"))

    visit root_path

    expect(page).to have_css("link[rel='shortcut icon'][href$='favicon_custom.ico']", visible: :hidden)
  end

  scenario "Custom auth background" do
    stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "auth_bg" => [260, 80] })
    create(:site_customization_image,
           name: "auth_bg",
           image: fixture_file_upload("logo_header-260x80.png"))

    visit new_user_session_path

    expect(page).to have_css "[style*='background-image:'][style*='logo_header-260x80.png']"
    expect(page).not_to have_css "[style*='auth_bg']"
  end
end
