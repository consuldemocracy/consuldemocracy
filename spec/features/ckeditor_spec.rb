require "rails_helper"

describe "CKEditor" do
  scenario "is present before & after turbolinks update page", :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    within(".translatable-fields[data-locale='en']") do
      expect(page).to have_css ".cke_textarea_inline[aria-label*='debate'][aria-label*='description']"
    end

    click_link "Debates"
    click_link "Start a debate"

    within(".translatable-fields[data-locale='en']") do
      expect(page).to have_css ".cke_textarea_inline[aria-label*='debate'][aria-label*='description']"
    end
  end

  scenario "uploading an image through the upload tab", :js do
    login_as(create(:administrator).user)

    visit new_admin_site_customization_page_path
    fill_in_ckeditor "Content", with: "Focus to make toolbar appear"
    click_link "Image"
    click_link "Upload"

    within_frame(0) do
      attach_file "Send it to the Server", Rails.root.join("spec/fixtures/files/clippy.jpg")
    end

    click_link "Send it to the Server"

    expect(page).to have_css "img[src$='clippy.jpg']"
  end
end
