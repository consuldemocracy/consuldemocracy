require "rails_helper"

describe "Watch form changes", :js do
  let(:prompt) { "You have unsaved changes. Do you confirm to leave the page?" }

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  describe "when form includes html editor" do
    let(:custom_page) { create(:site_customization_page, title: "Original title") }
    let(:path) { edit_admin_site_customization_page_path(custom_page) }

    context "should ask for confirmation before leaving the current page" do
      scenario "when any form input was modified" do
        visit path

        fill_in "Title", with: "Unsaved title"
        dismiss_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_current_path(path)
      end

      scenario "when any form input was modified and page was restored from browser history" do
        visit path

        fill_in "Title", with: "Unsaved title"
        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")

        go_back

        expect(page).to have_field("Title", with: "Unsaved title")

        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")
      end
    end

    context "should not ask for confirmation before leaving the current page" do
      scenario "when users restores original form data" do
        visit path

        expect(page).to have_ckeditor("Content", with: "This page is about...")

        fill_in_ckeditor("Content", with: "New content for editor.")
        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")

        go_back

        expect(page).to have_ckeditor("Content", with: "New content for editor.")

        fill_in_ckeditor("Content", with: "This page is about...")

        expect(page).to have_ckeditor("Content", with: "This page is about...")

        click_link "Proposals", match: :first

        expect(page).to have_text(:h2, "Proposals")
      end
    end
  end

  describe "when form does not include html editor" do
    let(:legislation_process) { create(:legislation_process, title: "An example legislation process") }
    let(:legislation_draft_version) do
      create(:legislation_draft_version, title: "Version 1", process: legislation_process)
    end
    let(:path) do
      edit_admin_legislation_process_draft_version_path(legislation_process, legislation_draft_version)
    end

    context "should ask for confirmation before leaving the current page" do
      scenario "when any form input was modified" do
        visit path

        fill_in "Changes", with: "Version 1b"
        dismiss_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_current_path(path)
      end

      scenario "when any form input was modified and page was restored from browser history" do
        visit path

        fill_in "Changes", with: "Version 1b"
        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")

        go_back

        expect(page).to have_content legislation_process.title

        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")
      end
    end

    context "should not ask for confirmation before leaving the current page" do
      scenario "when users restores original form data" do
        visit path

        fill_in "Changes", with: "Version 1b"
        accept_confirm(prompt) do
          click_link "Proposals", match: :first
        end

        expect(page).to have_text(:h2, "Proposals")

        go_back

        expect(page).to have_content legislation_process.title

        fill_in "Changes", with: legislation_draft_version.changelog

        click_link "Proposals", match: :first

        expect(page).to have_text(:h2, "Proposals")
      end
    end
  end
end
