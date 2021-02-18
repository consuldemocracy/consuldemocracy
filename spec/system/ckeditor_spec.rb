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

  scenario "uploading an image through the upload tab", :js, :admin do
    visit new_admin_site_customization_page_path
    fill_in_ckeditor "Content", with: "Filling in to make sure CKEditor is loaded"
    find(".cke_button__image").click

    expect(page).to have_css(".cke_dialog")

    execute_script "document.getElementsByClassName('cke_dialog')[0].style.left = '0px'"
    execute_script "document.getElementsByClassName('cke_dialog')[0].style.top = '0px'"

    expect(find(".cke_dialog")).to match_style(left: "0px", top: "0px")

    click_link "Upload"

    within_frame(1) do
      attach_file "Send it to the Server", Rails.root.join("spec/fixtures/files/clippy.jpg")
    end

    click_link "Send it to the Server"

    expect(page).to have_css "img[src$='clippy.jpg']"
  end

  scenario "cannot upload attachments through link tab", :js, :admin do
    visit new_admin_site_customization_page_path
    fill_in_ckeditor "Content", with: "Filling in to make sure CKEditor is loaded"
    find(".cke_button__link").click

    expect(page).to have_css(".cke_dialog")
    expect(page).not_to have_link "Upload"
    expect(page).not_to have_link "Browse Server"
  end

  context "When navigating back to editor page using browser history back" do
    scenario "display ckeditor unsaved contents", :js, :admin do
      visit new_admin_newsletter_path
      fill_in_ckeditor "Email content", with: "This is an unsaved body"
      click_link "Newsletters"

      expect(page).to have_link "New newsletter"

      go_back

      expect(page).to have_ckeditor "Email content", with: "This is an unsaved body"
    end
  end
end
