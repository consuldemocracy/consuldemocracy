require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  scenario "Is not shown when feature is disabled" do
    Setting["feature.cookies_consent"] = false

    visit root_path

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  scenario "Hides the cookies consent banner when accepted and for consecutive visits" do
    visit root_path

    within ".cookies-consent-banner" do
      click_button "Accept"
    end

    expect(page).not_to have_css(".cookies-consent-banner")

    visit root_path

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  context "when setup page is disabled" do
    before { Setting["cookies_consent.setup_page"] = false }

    scenario "does not show the notice with the instructions to edit cookies preferences" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Accept"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_content("Your cookies preferences were saved!")
    end
  end

  context "when setup page is enabled" do
    before { Setting["cookies_consent.setup_page"] = true }

    scenario "Hides the cookies consent banner when rejected and for consecutive visits" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Reject"
      end

      expect(page).not_to have_css(".cookies-consent-banner")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "Shows a link to open the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      expect(page).to have_css(".cookies-consent-setup")
      expect(page).to have_css("h2", text: "Cookies setup")
    end

    scenario "Allow users to accept all cookies from the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept all"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_css(".cookies-consent-setup")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "Allow users to accept essential cookies from the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept essential cookies"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_css(".cookies-consent-setup")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "shows a notice with instructions to edit cookies preferences" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button ["Accept", "Reject"].sample
      end

      expect(page).to have_content("Your cookies preferences were saved! You can change them")
      expect(page).to have_content("anytime from the \"Cookies setup\" link in the page footer.")
    end

    context "when third party cookie vendors are defined" do
      before do
        script = "$('body').append('Running third party script');"
        Cookies::Vendor.create!(name: "Vendor Name", cookie: "a_vendor_name", script: script)
        Cookies::Vendor.create!(name: "Cool Vendor", cookie: "cool_vendor_brand", script: script)
      end
      let(:vendor_1) { Cookies::Vendor.first }
      let(:vendor_2) { Cookies::Vendor.last }

      scenario "users can accept all at once" do
        visit root_path
        within ".cookies-consent-banner" do
          click_button "Setup"
        end
        within ".cookies-consent-setup" do
          click_button "Accept all"
        end

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).not_to have_css(".cookies-consent-setup")
        expect(page).to have_content("Running third party script", count: 2)

        click_link "Cookies setup"

        within "#cookies_vendor_#{vendor_1.id}" do
          expect(page).to have_css("label", text: "Yes")
        end
        within "#cookies_vendor_#{vendor_2.id}" do
          expect(page).to have_css("label", text: "Yes")
        end

        visit root_path

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).not_to have_css(".cookies-consent-setup")
        expect(page).to have_content("Running third party script", count: 2)
      end

      scenario "users can reject third party cookies" do
        visit root_path
        within ".cookies-consent-banner" do
          click_button "Setup"
        end
        within ".cookies-consent-setup" do
          click_button "Accept essential cookies"
        end

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).not_to have_css(".cookies-consent-setup")
        expect(page).not_to have_content("Running third party script", count: 2)

        click_link "Cookies setup"

        within "#cookies_vendor_#{vendor_1.id}" do
          expect(page).to have_css("label", text: "No")
        end
        within "#cookies_vendor_#{vendor_2.id}" do
          expect(page).to have_css("label", text: "No")
        end

        visit root_path

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).not_to have_content("Running third party script")
        expect(page).not_to have_content("Running third party script", count: 2)
      end

      scenario "users can select which cookies accept or deny independently" do
        visit root_path
        within ".cookies-consent-banner" do
          click_button "Setup"
        end
        within ".cookies-consent-setup" do
          within "#cookies_vendor_#{vendor_1.id}" do
            find("label", text: "No").click
          end

          click_button "Save preferences"
        end

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).to have_content("Running third party script", count: 1)

        visit root_path

        expect(page).not_to have_css(".cookies-consent-banner")
        expect(page).to have_content("Running third party script", count: 1)

        click_link "Cookies setup"

        within "#cookies_vendor_#{vendor_1.id}" do
          expect(page).to have_css("label", text: "Yes")
        end
        within "#cookies_vendor_#{vendor_2.id}" do
          expect(page).to have_css("label", text: "No")
        end

        within ".cookies-consent-setup" do
          within "#cookies_vendor_#{vendor_2.id}" do
            find("label", text: "No").click
          end

          click_button "Save preferences"
        end

        expect(page).to have_content("Running third party script", count: 2)

        visit root_path

        expect(page).to have_content("Running third party script", count: 2)
      end
    end
  end

  describe "when admin test mode is enabled" do
    before { Setting["cookies_consent.admin_test_mode"] = true }

    scenario "shows the cookie banner when an administrator user is logged in" do
      login_as(create(:administrator).user)

      visit root_path

      expect(page).to have_css(".cookies-consent-banner")
    end

    scenario "does not show the cookie banner for when the user is not an administrator" do
      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")

      login_as(create(:user))

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end
  end
end
