require "rails_helper"

describe "Cards", :admin do
  scenario "Create header with image" do
    visit admin_homepage_path
    click_link "Create header"

    fill_in "Title", with: "Welcome"
    fill_in_ckeditor "Description", with: "Header description"
    attach_image_to_card
    click_button "Create header"

    expect(page).to have_content "Card created successfully!"

    visit root_path

    expect(page).not_to have_selector "#header_background_image"
    expect(page).to have_selector "#header_image"
  end

  scenario "Create header with image as background" do
    visit admin_homepage_path
    click_link "Create header"

    fill_in "Title", with: "Welcome"
    fill_in_ckeditor "Description", with: "Header description"
    attach_image_to_card
    check "Use image as background"
    click_button "Create header"

    expect(page).to have_content "Card created successfully!"

    visit root_path

    expect(page).to have_selector "#header_background_image"
    expect(page).not_to have_selector "#header_image"
  end

  scenario "Create header without image" do
    visit admin_homepage_path
    click_link "Create header"

    fill_in "Title", with: "Welcome"
    fill_in_ckeditor "Description", with: "Header description"
    click_button "Create header"

    expect(page).to have_content "Card created successfully!"

    visit root_path

    expect(page).not_to have_selector "#header_background_image"
    expect(page).not_to have_selector "#header_image"
  end

  scenario "Checkbox of image as background does not appear on regular cards" do
    visit admin_homepage_path
    click_link "Create card"

    expect(page).not_to have_content "Use image as background"
  end

  def attach_image_to_card
    click_link "Add image"
    attach_file "Choose image", file_fixture("clippy.jpg")

    expect(page).to have_field("widget_card_image_attributes_title", with: "clippy.jpg")
  end
end
