require 'rails_helper'

feature "Admin newsletter emails" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
    create(:budget)
  end

  scenario "Show" do
    newsletter = create(:newsletter, subject: "This is a subject",
                                     segment_recipient: 'all_users',
                                     from: "no-reply@consul.dev",
                                     body: "This is a body")

    visit admin_newsletter_path(newsletter)

    expect(page).to have_content "This is a subject"
    expect(page).to have_content I18n.t("admin.segment_recipient.#{newsletter.segment_recipient}")
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Index" do
    3.times { create(:newsletter) }

    visit admin_newsletters_path

    expect(page).to have_css(".newsletter", count: 3)

    Newsletter.all.each do |newsletter|
      within("#newsletter_#{newsletter.id}") do
        expect(page).to have_content newsletter.subject
        expect(page).to have_content I18n.t("admin.segment_recipient.#{newsletter.segment_recipient}")
      end
    end
  end

  scenario "Create" do
    visit admin_newsletters_path
    click_link "New newsletter"

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: "Proposal authors",
                            body: "This is a body" )
    click_button "Create Newsletter"

    expect(page).to have_content "Newsletter created successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content "Proposal authors"
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Update" do
    newsletter = create(:newsletter)

    visit admin_newsletters_path
    within("#newsletter_#{newsletter.id}") do
      click_link "Edit"
    end

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: "Investment authors in the current budget",
                            body: "This is a body" )
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
    within("#newsletter_#{newsletter.id}") do
      click_link "Delete"
    end

    expect(page).to have_content "Newsletter deleted successfully"
    expect(page).to have_css(".newsletter", count: 0)
  end

  scenario 'Errors on create' do
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

  scenario "Send newsletter email", :js do
    newsletter = create(:newsletter)
    visit admin_newsletter_path(newsletter)

    click_link "Send"

    total_users = newsletter.list_of_recipients.count
    page.accept_confirm("Are you sure you want to send this newsletter to #{total_users} users?")

    expect(page).to have_content "Newsletter sent successfully"
  end

  scenario "Select list of users to send newsletter" do
    UserSegments::SEGMENTS.each do |user_segment|
      visit new_admin_newsletter_path

      fill_in_newsletter_form
      select I18n.t("admin.segment_recipient.#{user_segment}"), from: 'newsletter_segment_recipient'
      click_button "Create Newsletter"

      expect(page).to have_content(I18n.t("admin.segment_recipient.#{user_segment}"))
    end
  end
end
