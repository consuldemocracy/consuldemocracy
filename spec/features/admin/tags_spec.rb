require 'rails_helper'

feature 'Admin tags' do

  background do
    @tag1 = create(:tag)
    login_as(create(:administrator).user)
  end

  scenario 'Index' do
    create(:debate, tag_list: 'supertag')
    visit admin_tags_path

    expect(page).to have_content @tag1.name
    expect(page).to have_content 'supertag'
  end

  scenario 'Create' do
    visit admin_tags_path

    expect(page).to_not have_content 'important issues'

    within("form.new_tag") do
      fill_in "tag_name", with: 'important issues'
      click_button 'Create Topic'
    end

    visit admin_tags_path

    expect(page).to have_content 'important issues'
  end

  scenario 'Update' do
    visit admin_tags_path
    featured_checkbox = find("#tag_featured_#{@tag1.id}")
    expect(featured_checkbox.checked?).to be_nil

    within("#edit_tag_#{@tag1.id}") do
      check "tag_featured_#{@tag1.id}"
      click_button 'Update Topic'
    end

    visit admin_tags_path
    featured_checkbox = find("#tag_featured_#{@tag1.id}")
    expect(featured_checkbox.checked?).to eq('checked')
  end

  scenario 'Delete' do
    tag2 = create(:tag, name: 'bad tag')
    create(:debate, tag_list: tag2.name)
    visit admin_tags_path

    expect(page).to have_content @tag1.name
    expect(page).to have_content tag2.name

    within("#edit_tag_#{tag2.id}") do
      click_link 'Destroy Topic'
    end

    visit admin_tags_path
    expect(page).to have_content @tag1.name
    expect(page).to_not have_content tag2.name
  end

  scenario 'Delete tag with hidden taggables' do
    tag2 = create(:tag, name: 'bad tag')
    debate = create(:debate, tag_list: tag2.name)
    debate.hide

    visit admin_tags_path

    expect(page).to have_content @tag1.name
    expect(page).to have_content tag2.name

    within("#edit_tag_#{tag2.id}") do
      click_link 'Destroy Topic'
    end

    visit admin_tags_path
    expect(page).to have_content @tag1.name
    expect(page).to_not have_content tag2.name
  end

end