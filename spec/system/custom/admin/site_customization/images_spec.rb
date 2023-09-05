require "rails_helper"

describe "Admin custom images", :admin do
  scenario "List of customizable images" do
    valid_images = SiteCustomization::Image::VALID_IMAGES
    %w[logo_header social_media_icon social_media_icon_twitter apple-touch-icon-200 budget_execution_no_image
       budget_no_image budget_investment_no_image map logo_email welcome_process favicon
       welcome/step_1 welcome/step_2 welcome/step_3 auth_bg bg_footer logo_footer].each do |image_name|
      expect(valid_images.keys).to include(image_name)
    end
  end

  scenario "Upload image with more than required dimensions is valid" do
    visit admin_site_customization_images_path

    within("tr#image_logo_header") do
      attach_file "site_customization_image_image", file_fixture("example_large.jpg")
      click_button "Update"
    end

    expect(page).to have_css("tr#image_logo_header img[src*='example_large.jpg']")
    expect(page).to have_css("img[src*='example_large.jpg']", count: 1)
  end

  scenario "Upload image with same required dimensions is valid" do
    visit admin_site_customization_images_path

    within("tr#image_budget_no_image") do
      attach_file "site_customization_image_image", file_fixture("example.jpg")
      click_button "Update"
    end

    expect(page).to have_css("tr#image_budget_no_image img[src*='example.jpg']")
    expect(page).to have_css("img[src*='example.jpg']", count: 1)
  end

  scenario "Upload an image with less required dimensions is invalid" do
    visit admin_site_customization_images_path

    within("tr#image_budget_execution_no_image") do
      attach_file "site_customization_image_image", file_fixture("example_small.jpg")
      click_button "Update"
    end

    expect(page).to have_content("Width must be 800px")
    expect(page).to have_content("Height must be 600px")
  end
end
