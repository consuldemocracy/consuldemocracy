require 'rails_helper'

feature "Home" do

  scenario 'featured debates' do
    featured_debates = [create(:debate), create(:debate), create(:debate)]

    visit root_path

    expect(page).to have_selector('#featured-debates .debate-featured', count: 3)
    featured_debates.each do |debate|
      within('#featured-debates') do
        expect(page).to have_content debate.title
        expect(page).to have_css("a[href='#{debate_path(debate)}']", text: debate.description)
      end
    end

  end

end
