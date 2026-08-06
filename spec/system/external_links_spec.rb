require "rails_helper"

describe "Warning for external links" do
  before do
    proxy.stub("http://www.gnu.org/licenses/agpl-3.0.html").and_return(body: "<html></html>", code: 200)
  end

  context "when the feature is enabled" do
    before { Setting["feature.gdpr.warning_for_external_links"] = true }

    scenario "warns before leaving to an external website" do
      visit root_path

      accept_confirm("By confirming, you agree to leave the website.") do
        click_link "open-source software"
      end

      expect(page).to have_current_path "http://www.gnu.org/licenses/agpl-3.0.html"
    end

    scenario "cancels navigation when the user dismisses the confirm dialog" do
      visit root_path

      dismiss_confirm do
        click_link "open-source software"
      end

      expect(page).to have_current_path root_path
    end

    scenario "does not warn when using the CKEditor link button", :admin do
      visit new_admin_site_customization_page_path
      fill_in_ckeditor "Content", with: "Filling in to make sure CKEditor is loaded"

      find(".cke_button__link").click

      expect(page).to have_css ".cke_dialog"

      find(".cke_dialog_close_button").click

      expect(page).not_to have_css ".cke_dialog"
      expect(page).to have_current_path new_admin_site_customization_page_path
    end
  end

  scenario "does not warn when the feature is disabled" do
    Setting["feature.gdpr.warning_for_external_links"] = nil

    visit root_path

    click_link "open-source software"

    expect(page).to have_current_path "http://www.gnu.org/licenses/agpl-3.0.html"
  end
end
