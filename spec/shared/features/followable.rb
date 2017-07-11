shared_examples "followable" do |followable_class_name, followable_path, followable_path_arguments|
  include ActionView::Helpers

  let!(:arguments) { {} }
  let!(:followable) { create(followable_class_name) }
  let!(:followable_dom_name) { followable_class_name.gsub('_', '-') }

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
        expect(page).to have_link("Follow")
      end
    end

    scenario "Should display follow button when user is logged and is not following" do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)

      expect(page).to have_link("Follow")
    end

    scenario "Should display unfollow button when click on follow button", :js do
      user = create(:user)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link "Follow"
        page.find("#follow-#{followable_dom_name}-#{followable.id}").click

        expect(page).to have_css("#unfollow-expand-#{followable_dom_name}-#{followable.id}")
      end
    end

    scenario "Display unfollow button when user already following" do
      user = create(:user)
      follow = create(:follow, user: user, followable: followable)
      login_as(user)

      visit send(followable_path, arguments)

      expect(page).to have_link("Unfollow")
    end

    scenario "Should display follow button when click on unfollow button", :js do
      user = create(:user)
      follow = create(:follow, user: user, followable: followable)
      login_as(user)

      visit send(followable_path, arguments)
      within "##{dom_id(followable)}" do
        click_link "Unfollow"
        page.find("#unfollow-#{followable_dom_name}-#{followable.id}").click

        expect(page).to have_css("#follow-expand-#{followable_dom_name}-#{followable.id}")
      end
    end

  end

end
