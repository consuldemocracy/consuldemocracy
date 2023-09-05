require "rails_helper"

describe "Admin newsletter emails", :admin do
  scenario "Create with an image" do
    html_content = "<p>This newsletter have an image <img src=\"/image.jpg\" alt=\"Image title\"></img></p>"
    newsletter = create(:newsletter, body: html_content, segment_recipient: "administrators")

    visit edit_admin_newsletter_path(newsletter)

    within "#cke_newsletter_body" do
      expect(page).to have_css ".cke_button__image_icon"
    end

    visit admin_newsletters_path
    within "#newsletter_#{newsletter.id}" do
      click_link "Preview"
    end

    within ".newsletter-body-content" do
      expect(page).to have_css "img[src$=\"image.jpg\"]"
      expect(page).to have_css "img[alt=\"Image title\"]"
    end

    visit admin_newsletter_path(newsletter)

    accept_confirm { click_link "Send" }

    expect(page).to have_content "Newsletter sent successfully"

    email = open_last_email

    expect(email).to have_css "img[src$=\"image.jpg\"]"
    expect(email).to have_css "img[alt=\"Image title\"]"
  end
end
