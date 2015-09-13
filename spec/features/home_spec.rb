require 'rails_helper'

feature "Home" do

  feature "For not logged users" do
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

    scenario 'featured proposals' do
      featured_proposals = [create(:proposal), create(:proposal), create(:proposal)]

      visit root_path

      expect(page).to have_selector('#featured-proposals .proposal-featured', count: 3)
      featured_proposals.each do |proposal|
        within('#featured-proposals') do
          expect(page).to have_content proposal.title
          expect(page).to have_css("a[href='#{proposal_path(proposal)}']", text: proposal.description)
        end
      end
    end

    scenario "Order by confidence score" do
      create(:debate, confidence_score: 100, title: 'best debate')
      create(:debate, confidence_score: -20, title: 'worst debate')
      create(:debate, confidence_score: 50,  title: 'medium debate')

      create(:proposal, confidence_score: 100, title: 'best proposal')
      create(:proposal, confidence_score: -20, title: 'worst proposal')
      create(:proposal, confidence_score: 50,  title: 'medium proposal')

      visit root_path

      expect('best debate').to appear_before('medium debate')
      expect('medium debate').to appear_before('worst debate')
      expect('best proposal').to appear_before('medium proposal')
      expect('medium proposal').to appear_before('worst proposal')
    end
  end

  feature "For signed in users" do
    scenario 'debates and proposals order by hot_score' do
      create(:debate, title: 'best debate 100').update_column(:hot_score, 100)
      create(:debate, title: 'worst debate 50').update_column(:hot_score, 50)
      create(:debate, title: 'medium debate 70').update_column(:hot_score, 70)

      create(:proposal, title: 'best proposal 90').update_column(:hot_score, 90)
      create(:proposal, title: 'worst proposal 60').update_column(:hot_score, 60)
      create(:proposal, title: 'medium proposal 80').update_column(:hot_score, 80)

      login_as(create(:user))

      visit root_path

      expect('best debate 100').to    appear_before('best proposal 90')
      expect('best proposal 90').to   appear_before('medium proposal 80')
      expect('medium proposal 80').to appear_before('medium debate 70')
      expect('medium debate 70').to   appear_before('worst proposal 60')
      expect('worst proposal 60').to  appear_before('worst debate 50')
    end
  end

end
