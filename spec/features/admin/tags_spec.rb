require 'rails_helper'

feature 'Admin tags' do

  background do
    @tag1 = create(:tag, :category)
    login_as(create(:administrator).user)
  end

  scenario 'Index' do
    debate = create(:debate)
    debate.tag_list.add(create(:tag, :category, name: "supertag"))
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
    expect(featured_checkbox.checked?).to be_blank

    within("#edit_tag_#{@tag1.id}") do
      check "tag_featured_#{@tag1.id}"
      click_button 'Update Topic'
    end

    visit admin_tags_path
    featured_checkbox = find("#tag_featured_#{@tag1.id}")
    expect(featured_checkbox.checked?).to eq(true)
  end

  scenario 'Delete' do
    tag2 = create(:tag, :category, name: "bad tag")
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
    tag2 = create(:tag, :category, name: "bad tag")
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

  context "Manage only tags of kind category" do
    scenario "Index shows only categories" do
      not_category_tag = create(:tag, name: "Not a category")
      visit admin_tags_path

      expect(page).to have_content @tag1.name
      expect(page).to_not have_content "Not a category"
    end

    scenario "Create instanciates tags of correct kind" do
      visit admin_tags_path

      within("form.new_tag") do
        fill_in "tag_name", with: "wow_category"
        click_button 'Create Topic'
      end

      expect(ActsAsTaggableOn::Tag.category.where(name: "wow_category")).to exist
    end

    scenario "Update doesn't affect the category kind" do
      visit admin_tags_path

      within("#edit_tag_#{@tag1.id}") do
        check "tag_featured_#{@tag1.id}"
        click_button 'Update Topic'
      end

      expect(ActsAsTaggableOn::Tag.category.where(id: @tag1.id)).to exist
    end
  end

end
