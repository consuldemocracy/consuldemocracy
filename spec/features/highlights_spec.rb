require 'rails_helper'

feature "Highlights" do

  scenario 'Debates and proposals order by hot_score' do
    create(:debate, title: 'best debate 100').update_column(:hot_score, 100)
    create(:debate, title: 'worst debate 50').update_column(:hot_score, 50)
    create(:debate, title: 'medium debate 70').update_column(:hot_score, 70)

    create(:proposal, title: 'best proposal 90').update_column(:hot_score, 90)
    create(:proposal, title: 'worst proposal 60').update_column(:hot_score, 60)
    create(:proposal, title: 'medium proposal 80').update_column(:hot_score, 80)

    login_as(create(:user))

    visit highlights_path

    expect('best debate 100').to    appear_before('best proposal 90')
    expect('best proposal 90').to   appear_before('medium proposal 80')
    expect('medium proposal 80').to appear_before('medium debate 70')
    expect('medium debate 70').to   appear_before('worst proposal 60')
    expect('worst proposal 60').to  appear_before('worst debate 50')
  end

  scenario 'create debate and create proposal links' do
    login_as(create(:user))

    visit highlights_path

    expect(page).to have_link("Create a proposal")
    expect(page).to have_link("Start a debate")
  end

end