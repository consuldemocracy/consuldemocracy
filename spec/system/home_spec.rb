require "rails_helper"

describe "Home" do
  context "For not logged users" do
    scenario "Welcome message" do
      visit root_path

      expect(page).to have_content "CONSUL"
    end

    scenario "Creates a newsletter recipient" do
      visit root_path

      expect(page).to have_content "Newsletter"
      expect(page).to have_content "Not registered yet? Subscribe for newsletter now"
      fill_in "E-Mail", with: "test@test.test"
      click_button "Register"
      expect(page).to have_content "You have successfully subscribed!"
    end

    scenario "Newsletter recipient is already present" do
      record = [
        build(:user, email: "test@test.test"),
        build(:newsletter_recipient, email: "test@test.test")
      ].sample
      record.save

      visit root_path

      expect(page).to have_content "Newsletter"
      expect(page).to have_content "Not registered yet? Subscribe for newsletter now"
      fill_in "E-Mail", with: "test@test.test"
      click_button "Register"
      expect(page).to have_content "has already been taken"
    end

    scenario "Not display recommended section" do
      create(:debate)

      visit root_path

      expect(page).not_to have_content "Recommendations that may interest you"
    end
  end

  context "For signed in users" do
    describe "Recommended" do
      before do
        proposal = create(:proposal, tag_list: "Sport")
        user = create(:user, followables: [proposal])
        login_as(user)
      end

      scenario "Display recommended section when feature flag recommended is active" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_content "Recommendations that may interest you"
      end

      scenario "Not display recommended section when feature flag recommended is not active" do
        create(:debate, tag_list: "Sport")
        Setting["feature.user.recommendations"] = false

        visit root_path

        expect(page).not_to have_content "Recommendations that may interest you"
      end

      scenario "Display debates" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_content debate.title
        expect(page).to have_content debate.description
      end

      scenario "Displays newsletter subscription" do
        visit root_path

        within(".feeds-participation") do
          button = find_button("Newsletter recipient")
          expect(button).to have_text("Yes")
          button.click

          expect(button).to have_text("No")
        end
      end

      scenario "Display all recommended debates link" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_link("All recommended debates", href: debates_path(order: "recommendations"))
      end

      scenario "Display proposal" do
        proposal = create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).to have_content proposal.title
        expect(page).to have_content proposal.description
      end

      scenario "Display all recommended proposals link" do
        create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).to have_link("All recommended proposals", href: proposals_path(order: "recommendations"))
      end

      scenario "Display orbit carrousel" do
        create_list(:debate, 3, tag_list: "Sport")

        visit root_path

        expect(page).to have_css "li[data-slide='0']"
        expect(page).to have_css "li[data-slide='1']", visible: :hidden
        expect(page).to have_css "li[data-slide='2']", visible: :hidden
      end

      scenario "Display recommended show when click on carousel" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        within("#section_recommended") do
          click_link debate.title
        end

        expect(page).to have_current_path(debate_path(debate))
      end

      scenario "Do not display recommended section when there are not debates and proposals" do
        visit root_path
        expect(page).not_to have_content "Recommendations that may interest you"
      end
    end
  end

  describe "Menu button" do
    scenario "is not present on large screens" do
      visit root_path

      expect(page).not_to have_button "Menu"
    end

    scenario "toggles the menu on small screens", :small_window do
      visit root_path

      expect(page).not_to have_link "Sign in"

      click_button "Menu"

      expect(page).to have_link "Sign in"
    end
  end

  scenario "if there are cards, the 'featured' title will render" do
    create(
      :widget_card,
      title: "Card text",
      description: "Card description",
      link_text: "Link text",
      link_url: "consul.dev"
    )

    visit root_path

    expect(page).to have_css(".title", text: "Featured")
  end

  scenario "if there are no cards, the 'featured' title will not render" do
    visit root_path

    expect(page).not_to have_css(".title", text: "Featured")
  end

  scenario "cards are first sorted by 'order' field, then by 'created_at' when order is equal" do
    create(:widget_card, title: "Card one", order: 1)
    create(:widget_card, title: "Card two", order: 3)
    create(:widget_card, title: "Card three", order: 2)
    create(:widget_card, title: "Card four", order: 3)

    visit root_path

    within(".cards-container") do
      expect("CARD ONE").to appear_before("CARD THREE")
      expect("CARD THREE").to appear_before("CARD TWO")
      expect("CARD TWO").to appear_before("CARD FOUR")
    end
  end

  describe "Header Card" do
    scenario "if there is header card with link, the link content is rendered" do
      create(:widget_card, :header, link_text: "Link text", link_url: "consul.dev")

      visit root_path

      expect(page).to have_link "Link text", href: "consul.dev"
    end

    scenario "if there is header card without link, the link content is not rendered" do
      create(:widget_card, :header, link_text: nil, link_url: nil)

      visit root_path

      within(".header-card") { expect(page).not_to have_link }
    end

    scenario "if there is header card without link and with text, the link content is not rendered" do
      create(:widget_card, :header, link_text: "", link_url: "", link_text_es: "Link ES", title_es: "ES")

      visit root_path(locale: :es)

      within(".header-card") { expect(page).not_to have_link }
    end
  end

  describe "Link to skip to main content" do
    it "is visible on focus" do
      visit root_path

      expect(page).to have_link "Skip to main content", visible: :hidden
      expect(page).to have_css "main"
      expect(page).not_to have_css "main:target"

      page.execute_script("$('.skip-to-main-content a').focus()")
      sleep 0.01 until page.has_link?("Skip to main content", visible: :visible)
      click_link "Skip to main content"

      expect(page).to have_css "main:target"
    end
  end
end
