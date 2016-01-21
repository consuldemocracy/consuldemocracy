require 'rails_helper'

feature 'Admin categories' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Can create new categories", :js do
    visit admin_categories_path

    click_link "Create axis"

    fill_in "category_position", with: 1
    fill_in "name_ca", with: "Eix 1"
    fill_in "name_es", with: "Eje 1"
    fill_in "name_en", with: "Axis 1"
    fill_in_ckeditor 'description_ca', with: 'Aquesta es una categoria'
    fill_in_ckeditor 'description_es', with: 'Esta es una categoría'
    fill_in_ckeditor 'description_en', with: 'This is a category'

    click_button "Create axis"

    expect(page).to have_content "Category created successfully."
    expect(page).to have_content("1. Axis 1")
  end

  scenario "Edit an existing category", :js do
    create(:category, name: { en: "My axis" })

    visit admin_categories_path

    click_link "Edit"

    fill_in "name_en", with: "My edited axis"

    click_button "Update axis"

    expect(page).to have_content "Category updated successfully."
    expect(page).to have_content("My edited axis")
  end

end
