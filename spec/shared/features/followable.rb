shared_examples "followable" do |followable_class_name, followable_path, followable_path_arguments|
  include ActionView::Helpers

  let!(:arguments) { {} }
  let!(:followable) { create(followable_class_name) }
  let!(:followable_dom_name) { followable_class_name.tr("_", "-") }

  before do
    followable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": followable.send(path_to_value))
    end
  end

  context "Show" do

    scenario "Should not display follow button when there is no logged user" do
      visit send(followable_path, arguments)

      within "##{dom_id(followable)}" do
        expect(page).not_to have_link("Follow")
      end
    end

    scenario "Should display follow button when user is logged in" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)

      within "##{dom_id(followable)}" do
        expect(page).to have_link("Follow #{followable.model_name.human.downcase}")
      end
    end

    scenario "Should display follow button when user is logged and is not following" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      expect(page).to have_link("Follow #{followable.model_name.human.downcase}")
    end

    scenario "Should display unfollow after user clicks on follow button", :js do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link("Follow #{followable.model_name.human.downcase}")

        expect(page).not_to have_link("Follow")
        expect(page).to have_link("Following")
      end
    end

    scenario "Should display new follower notice after user clicks on follow button", :js do
      user = create(:user)
      login_as(user)
      create_notice_message = t("shared.followable.#{followable_class_name}.create.notice_html")

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link("Follow #{followable.model_name.human.downcase}")
      end

      expect(page).to have_content strip_tags(create_notice_message)
    end

    scenario "Display unfollow button when user already following" do
      user = create(:user)
      follow = create(:follow, user: user, followable: followable)
      login_as(user)

      visit send(followable_path, arguments)

      expect(page).to have_link("Following")
    end

    scenario "Updates follow button & show destroy notice after unfollow button is clicked", :js do
      user = create(:user)
      follow = create(:follow, user: user, followable: followable)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link("Unfollow #{followable.model_name.human.downcase}")

        expect(page).not_to have_link("Unfollow")
        expect(page).to have_link("Follow #{followable.model_name.human.downcase}")
      end
    end

    scenario "Should display destroy follower notice after user clicks on unfollow button", :js do
      user = create(:user)
      follow = create(:follow, user: user, followable: followable)
      login_as(user)
      destroy_notice_message = t("shared.followable.#{followable_class_name}.destroy.notice_html")

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link("Unfollow #{followable.model_name.human.downcase}")
      end

      expect(page).to have_content strip_tags(destroy_notice_message)
    end

  end

end
