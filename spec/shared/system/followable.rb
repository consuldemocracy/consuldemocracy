shared_examples "followable" do |followable_class_name, followable_path, followable_path_arguments|
  let!(:arguments) { {} }
  let!(:followable) { create(followable_class_name) }

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end

  before do
    followable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": followable.send(path_to_value))
    end
  end

  context "Show" do
    scenario "Should not display follow button when there is no logged user" do
      visit send(followable_path, arguments)

      within "##{dom_id(followable)}" do
        expect(page).not_to have_button("Follow")
      end
    end

    scenario "Should display follow button when user is logged in" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)

      within "##{dom_id(followable)}" do
        expect(page).to have_button("Follow #{followable.model_name.human.downcase}")
      end
    end

    scenario "Should display follow button when user is logged and is not following" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      expect(page).to have_button("Follow #{followable.model_name.human.downcase}")
    end

    scenario "Should display unfollow after user clicks on follow button" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_button("Follow #{followable.model_name.human.downcase}")

        expect(page).not_to have_button("Follow")
        expect(page).to have_button("Following")
      end
    end

    scenario "Should display new follower notice after user clicks on follow button" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_button("Follow #{followable.model_name.human.downcase}")
      end

      expect(page).to have_content "We will notify you of changes as they occur"
    end

    scenario "Display unfollow button when user already following" do
      user = create(:user, followables: [followable])
      login_as(user)

      visit send(followable_path, arguments)

      expect(page).to have_button("Following")
    end

    scenario "Updates follow button & show destroy notice after unfollow button is clicked" do
      user = create(:user, followables: [followable])
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_button("Unfollow #{followable.model_name.human.downcase}")

        expect(page).not_to have_button("Unfollow")
        expect(page).to have_button("Follow #{followable.model_name.human.downcase}")
      end
    end

    scenario "Should display destroy follower notice after user clicks on unfollow button" do
      user = create(:user, followables: [followable])
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_button("Unfollow #{followable.model_name.human.downcase}")
      end

      expect(page).to have_content "You will no longer receive notifications"
    end
  end
end
