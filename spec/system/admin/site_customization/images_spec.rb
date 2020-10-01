require "rails_helper"

describe "Admin custom images" do
  before do
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

  scenario "Image is replaced on front views" do
    budget = create(:budget)
    group = create(:budget_group, budget: budget)
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

    visit map_proposals_path

    within(".show-for-medium") do
      expect(page).to have_css("img[src*='custom_map.jpg']")
    end

    visit budget_group_path(budget, group)

    within(".show-for-medium") do
      expect(page).to have_css("img[src*='custom_map.jpg']")
    end
  end

  scenario "Image is replaced on admin newsletters" do
    newsletter = create(:newsletter, segment_recipient: "all_users")

    visit admin_site_customization_images_path

    within("tr#image_logo_email") do
      attach_file "site_customization_image_image", "spec/fixtures/files/logo_email_custom.png"
      click_button "Update"
    end

    visit admin_newsletter_path(newsletter)

    within(".newsletter-body-content") do
      expect(page).to have_css("img[src*='logo_email_custom.png']")
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

  scenario "Upload image with more than required dimensions is valid" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_header_homepage") do
      attach_file "site_customization_image_image", "spec/fixtures/files/header_homepage_large.jpg"
      click_button "Update"
    end

    expect(page).to have_css("tr#image_header_homepage img[src*='header_homepage_large.jpg']")
    expect(page).to have_css("img[src*='header_homepage_large.jpg']", count: 1)
  end

  scenario "Upload image with same required dimensions is valid" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_header_homepage") do
      attach_file "site_customization_image_image", "spec/fixtures/files/header_homepage.jpg"
      click_button "Update"
    end

    expect(page).to have_css("tr#image_header_homepage img[src*='header_homepage.jpg']")
    expect(page).to have_css("img[src*='header_homepage.jpg']", count: 1)
  end

  scenario "Upload an image with less required dimensions is invalid" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Custom images"
    end

    within("tr#image_header_homepage") do
      attach_file "site_customization_image_image", "spec/fixtures/files/header_homepage_small.jpg"
      click_button "Update"
    end

    expect(page).to have_content("Width must be 500px")
    expect(page).to have_content("Height must be 400px")
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
