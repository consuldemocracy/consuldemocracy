require "rails_helper"

describe "Admin newsletter emails", :admin do
  before do
    create(:budget)
  end

  context "Show" do
    scenario "Valid newsletter" do
      newsletter = create(:newsletter, subject: "This is a subject",
                                       segment_recipient: "all_users",
                                       from: "no-reply@consul.dev",
                                       body: "This is a body")

      visit admin_newsletter_path(newsletter)

      expect(page).to have_link "Go back", href: admin_newsletters_path
      expect(page).to have_content "This is a subject"
      expect(page).to have_content "All users"
      expect(page).to have_content "no-reply@consul.dev"
      expect(page).to have_content "This is a body"
    end

    scenario "Invalid newsletter" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")

      visit admin_newsletter_path(invalid_newsletter)

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  context "Index" do
    scenario "Valid newsletters" do
      newsletters = 3.times.map { create(:newsletter) }

      visit admin_newsletters_path

      expect(page).to have_css(".newsletter", count: 3)

      newsletters.each do |newsletter|
        within("#newsletter_#{newsletter.id}") do
          expect(page).to have_content newsletter.subject
          expect(page).to have_content UserSegments.segment_name(newsletter.segment_recipient)
        end
      end
    end

    scenario "Invalid newsletter" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")

      visit admin_newsletters_path

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  scenario "Create" do
    segment_recipient = I18n.t("admin.segment_recipient.#{UserSegments.segments.sample}")
    visit admin_newsletters_path
    click_link "New newsletter"

    expect(page).to have_link "Go back", href: admin_newsletters_path

    within("#newsletter_segment_recipient") do
      expect(page).to have_css("option", text: "All users + newsletter recipients")
    end

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: segment_recipient,
                            body: "This is a body")
    click_button "Create Newsletter"

    expect(page).to have_content "Newsletter created successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content segment_recipient
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Update" do
    newsletter = create(:newsletter)

    visit admin_newsletters_path
    within("#newsletter_#{newsletter.id}") do
      click_link "Edit"
    end

    expect(page).to have_link "Go back", href: admin_newsletters_path

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: "Investment authors in the current budget",
                            body: "This is a body")
    click_button "Update Newsletter"

    expect(page).to have_content "Newsletter updated successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content "Investment authors in the current budget"
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Destroy" do
    newsletter = create(:newsletter)

    visit admin_newsletters_path

    confirmation = "Are you sure? This action will delete \"#{newsletter.subject}\" and can't be undone."
    within("#newsletter_#{newsletter.id}") do
      accept_confirm(confirmation) { click_button "Delete" }
    end

    expect(page).to have_content "Newsletter deleted successfully"
    expect(page).to have_css(".newsletter", count: 0)
  end

  scenario "Errors on create" do
    visit new_admin_newsletter_path

    click_button "Create Newsletter"

    expect(page).to have_content error_message
  end

  scenario "Errors on update" do
    newsletter = create(:newsletter)
    visit edit_admin_newsletter_path(newsletter)

    fill_in "newsletter_subject", with: ""
    click_button "Update Newsletter"

    expect(page).to have_content error_message
  end

  context "Send newsletter" do
    scenario "Sends newsletter emails" do
      newsletter = create(:newsletter)
      visit admin_newsletter_path(newsletter)

      accept_confirm { click_button "Send" }

      expect(page).to have_content "Newsletter sent successfully"
    end

    scenario "Invalid newsletter cannot be sent" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")
      visit admin_newsletter_path(invalid_newsletter)

      expect(page).not_to have_link("Send")
    end
  end

  context "Counter of emails sent" do
    scenario "Display counter" do
      newsletter = create(:newsletter, segment_recipient: "administrators")
      visit admin_newsletter_path(newsletter)

      accept_confirm { click_button "Send" }

      expect(page).to have_content "Newsletter sent successfully"

      expect(page).to have_content "1 affected users"
      expect(page).to have_content "1 email sent"
    end
  end

  describe "Select list of users to send newsletter" do
    scenario "Custom user segments" do
      segment = UserSegments.segments.sample
      segment_recipient = UserSegments.segment_name(segment)

      visit new_admin_newsletter_path

      fill_in_newsletter_form(segment_recipient: segment_recipient)
      click_button "Create Newsletter"

      expect(page).to have_content segment_recipient
    end

    scenario "Geozone segments" do
      create(:geozone, name: "Queens and Brooklyn")

      visit new_admin_newsletter_path

      fill_in_newsletter_form(segment_recipient: "Queens and Brooklyn")
      click_button "Create Newsletter"

      expect(page).to have_content "Queens and Brooklyn"
    end
  end
end
