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

  scenario "Order by confidence score" do
    create(:debate, confidence_score: 100, title: 'best')
    create(:debate, confidence_score: -20, title: 'worst')
    create(:debate, confidence_score: 50,  title: 'medium')

    visit root_path

    expect('best').to appear_before('medium')
    expect('medium').to appear_before('worst')
  end

end
