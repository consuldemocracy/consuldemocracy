require 'rails_helper'

feature 'Categories' do
  let!(:subcategory1){ create(:subcategory) }
  let!(:subcategory2){ create(:subcategory) }
  let(:category1){ subcategory1.category }
  let(:category2){ subcategory2.category }

  scenario "Shows all the categories and subcategories" do
    visit categories_path

    [category1, category2].each do |category| 
      expect(page).to have_content category.name["en"]
      expect(page).to have_content category.description["en"]
    end

    [subcategory1, subcategory2].each do |subcategory| 
      expect(page).to have_content subcategory.name["en"]
      expect(page).to have_content subcategory.description["en"]
    end
  end
end
