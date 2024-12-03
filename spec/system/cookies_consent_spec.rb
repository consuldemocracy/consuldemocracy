require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  scenario "Hides the cookies consent banner when accepted and for consecutive visits" do
    visit root_path

    within ".cookies-consent-banner" do
      click_button "Accept essential cookies"
    end

    expect(page).not_to have_css ".cookies-consent-banner"

    refresh

    expect(page).not_to have_css ".cookies-consent-banner"
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

    refresh

    expect(page).not_to have_css(".cookies-consent-banner")
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
end
