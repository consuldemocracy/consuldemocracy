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

  scenario "Upload valid png image" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Site content"
      click_link "Custom images"
    end

    within("tr#image_logo_header") do
      attach_file "site_customization_image_image", file_fixture("logo_header.png")
      click_button "Update"
    end

    expect(page).to have_css("tr#image_logo_header img[src*='logo_header.png']")
    expect(page).to have_css("img[src*='logo_header.png']", count: 1)
  end

  scenario "Upload valid jpg image" do
    visit admin_site_customization_images_path

    within("tr#image_map") do
      attach_file "site_customization_image_image", file_fixture("custom_map.jpg")
      click_button "Update"
    end

    expect(page).to have_css("tr#image_map img[src*='custom_map.jpg']")
    expect(page).to have_css("img[src*='custom_map.jpg']", count: 1)
  end

  scenario "Image is replaced on front views" do
    create(:geozone)
    budget = create(:budget)
    group = create(:budget_group, budget: budget)

    visit admin_site_customization_images_path

    within("tr#image_map") do
      attach_file "site_customization_image_image", file_fixture("custom_map.jpg")
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

  scenario "Custom apple touch icon is replaced on front views" do
    create(:site_customization_image,
           name: "apple-touch-icon-200",
           image: fixture_file_upload("apple-touch-icon-custom-200.png"))

    visit root_path

    expect(page).not_to have_css("link[href*='apple-touch-icon-200']", visible: :all)
    expect(page).to have_css("link[href*='apple-touch-icon-custom-200']", visible: :hidden)
  end

  scenario "Image is replaced on admin newsletters" do
    newsletter = create(:newsletter, segment_recipient: "all_users")

    visit admin_site_customization_images_path

    within("tr#image_logo_email") do
      attach_file "site_customization_image_image", file_fixture("logo_email_custom.png")
      click_button "Update"
    end

    visit admin_newsletter_path(newsletter)

    within(".newsletter-body-content") do
      expect(page).to have_css("img[src*='logo_email_custom.png']")
    end
  end

  scenario "Upload invalid image" do
    visit admin_site_customization_images_path

    within("tr#image_social_media_icon") do
      attach_file "site_customization_image_image", file_fixture("logo_header.png")
      click_button "Update"
    end

    expect(page).to have_content("Width must be 470px")
    expect(page).to have_content("Height must be 246px")
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

  scenario "Delete image" do
    visit admin_site_customization_images_path

    within("tr#image_social_media_icon") do
      attach_file "site_customization_image_image", file_fixture("social_media_icon.png")
      click_button "Update"
    end

    expect(page).to have_css("img[src*='social_media_icon.png']")

    within("tr#image_social_media_icon") do
      click_link "Delete"
    end

    expect(page).not_to have_css("img[src*='social_media_icon.png']")
  end
end
