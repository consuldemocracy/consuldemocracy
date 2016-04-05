require 'rails_helper'

feature 'Admin' do
  let(:user) { create(:user) }
  let(:administrator) do
    create(:administrator, user: user)
    user
  end

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit admin_root_path

    expect(current_path).not_to eq(admin_root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a moderator is not authorized' do
    create(:moderator, user: user)
    login_as(user)
    visit admin_root_path

    expect(current_path).not_to eq(admin_root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a valuator is not authorized' do
    create(:valuator, user: user)
    login_as(user)
    visit admin_root_path

    expect(current_path).not_to eq(admin_root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as an administrator is authorized' do
    login_as(administrator)
    visit admin_root_path

    expect(current_path).to eq(admin_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario "Admin access links" do
    login_as(administrator)
    visit root_path

    expect(page).to have_link('Administration')
    expect(page).to have_link('Moderation')
    expect(page).to have_link('Valuation')
  end

  scenario 'Admin dashboard' do
    login_as(administrator)
    visit root_path

    click_link 'Administration'

    expect(current_path).to eq(admin_root_path)
    expect(page).to have_css('#admin_menu')
    expect(page).to_not have_css('#moderation_menu')
    expect(page).to_not have_css('#valuation_menu')
  end

  context 'Tags' do
    let(:unfeatured_tag) { create :tag, :unfeatured, name: 'Mi barrio' }

    background do
      login_as(administrator)
    end

    scenario 'adding a new tag' do
      visit admin_tags_path

      fill_in 'tag_name', with: 'Papeleras'

      click_on 'Create Topic'

      expect(page).to have_content 'Papeleras'
    end

    scenario 'deleting tag' do
      unfeatured_tag

      visit admin_tags_path

      expect(page).to have_content 'Mi barrio'

      click_link 'Destroy Topic'

      expect(page).not_to have_content 'Mi barrio'
    end

    scenario 'marking tags as featured / unfeatured' do
      expect(unfeatured_tag).not_to be_featured

      visit admin_tags_path

      expect(page).to have_content 'Mi barrio'

      check "tag_featured_#{unfeatured_tag.id}"
      click_button 'Update Topic'

      expect(page).to have_checked_field("tag_featured_#{unfeatured_tag.id}")
    end
  end

end
