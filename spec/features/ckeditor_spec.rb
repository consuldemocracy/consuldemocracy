require "rails_helper"

describe "CKEditor" do
  scenario "is present before & after turbolinks update page", :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    expect(page).to have_css ".translatable-fields[data-locale='en'] .cke_wysiwyg_frame"

    click_link "Debates"
    click_link "Start a debate"

    expect(page).to have_css ".translatable-fields[data-locale='en'] .cke_wysiwyg_frame"
  end

  scenario "uploading an image through the upload tab", :js do
    login_as(create(:administrator).user)

    visit new_admin_site_customization_page_path
    fill_in_ckeditor "Content", with: "Filling in to make sure CKEditor is loaded"
    find(".cke_button__image").click
    click_link "Upload"

    within_frame(1) do
      attach_file "Send it to the Server", Rails.root.join("spec/fixtures/files/clippy.jpg")
    end

    click_link "Send it to the Server"

    expect(page).to have_css "img[src$='clippy.jpg']"
  end
end
