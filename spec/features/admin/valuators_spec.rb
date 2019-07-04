require "rails_helper"

feature "Admin valuators" do

  background do
    @admin    = create(:administrator)
    @user     = create(:user, username: "Jose Luis Balbin")
    @valuator = create(:valuator)
    login_as(@admin.user)
    visit admin_valuators_path
  end

  scenario "Show" do
    visit admin_valuator_path(@valuator)

    expect(page).to have_content @valuator.name
    expect(page).to have_content @valuator.description
    expect(page).to have_content @valuator.email
  end

  scenario "Index" do
    expect(page).to have_content(@valuator.name)
    expect(page).to have_content(@valuator.email)
    expect(page).not_to have_content(@user.name)
  end

  scenario "Create", :js do
    fill_in "name_or_email", with: @user.email
    click_button "Search"

    expect(page).to have_content(@user.name)
    click_button "Add to valuators"

    within("#valuators") do
      expect(page).to have_content(@user.name)
    end
  end

  scenario "Edit" do
    visit edit_admin_valuator_path(@valuator)

    fill_in "valuator_description", with: "Valuator for health"
    click_button "Update valuator"

    expect(page).to have_content "Valuator updated successfully"
    expect(page).to have_content @valuator.email
    expect(page).to have_content "Valuator for health"
  end

  scenario "Destroy" do
    click_link "Delete"

    within("#valuators") do
      expect(page).not_to have_content(@valuator.name)
    end
  end

  context "Search" do

    background do
      user  = create(:user, username: "David Foster Wallace", email: "david@wallace.com")
      user2 = create(:user, username: "Steven Erikson", email: "steven@erikson.com")
      @valuator1 = create(:valuator, user: user)
      @valuator2 = create(:valuator, user: user2)
      visit admin_valuators_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(@valuator1.name)
      expect(page).to have_content(@valuator2.name)

      fill_in "name_or_email", with: " "
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(@valuator1.name)
      expect(page).not_to have_content(@valuator2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(@valuator1.name)
      expect(page).to have_content(@valuator2.name)

      fill_in "name_or_email", with: "Foster"
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_content(@valuator1.name)
      expect(page).not_to have_content(@valuator2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(@valuator1.email)
      expect(page).to have_content(@valuator2.email)

      fill_in "name_or_email", with: @valuator2.email
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_content(@valuator2.email)
      expect(page).not_to have_content(@valuator1.email)
    end
  end

end
