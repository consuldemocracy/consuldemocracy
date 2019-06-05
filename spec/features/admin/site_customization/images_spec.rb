require "rails_helper"

feature "Admin custom images" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Upload valid png image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_logo_header") do
      attach_file "site_customization_image_image", "spec/fixtures/files/logo_header.png"
      click_button "Update"
    end

    expect(page).to have_css("tr#image_logo_header img[src*='logo_header.png']")
    expect(page).to have_css("img[src*='logo_header.png']", count: 1)
  end

  scenario "Upload valid jpg image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_map") do
      attach_file "site_customization_image_image", "spec/fixtures/files/custom_map.jpg"
      click_button "Update"
    end

    expect(page).to have_css("tr#image_map img[src*='custom_map.jpg']")
    expect(page).to have_css("img[src*='custom_map.jpg']", count: 1)
  end

  scenario "Image is replaced on front view" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_map") do
      attach_file "site_customization_image_image", "spec/fixtures/files/custom_map.jpg"
      click_button "Update"
    end

    visit proposals_path

    within("#map") do
      expect(page).to have_css("img[src*='custom_map.jpg']")
    end
  end

  scenario "Upload invalid image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_social_media_icon") do
      attach_file "site_customization_image_image", "spec/fixtures/files/logo_header.png"
      click_button "Update"
    end

    expect(page).to have_content("Width must be 470px")
    expect(page).to have_content("Height must be 246px")
  end

  scenario "Delete image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_social_media_icon") do
      attach_file "site_customization_image_image", "spec/fixtures/files/social_media_icon.png"
      click_button "Update"
    end

    expect(page).to have_css("img[src*='social_media_icon.png']")

    within("tr#image_social_media_icon") do
      click_link "Delete"
    end

    expect(page).not_to have_css("img[src*='social_media_icon.png']")
  end
end
