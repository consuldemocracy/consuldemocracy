require 'rails_helper'

feature 'Stats' do

  context 'Summary' do

    scenario 'General' do
      create(:debate)
      2.times { create(:proposal) }
      3.times { create(:comment, commentable: Debate.first) }
      4.times { create(:visit) }

      visit stats_path

      expect(page).to have_content "Debates 1"
      expect(page).to have_content "Proposals 2"
      expect(page).to have_content "Comments 3"
      expect(page).to have_content "Visits 4"
    end

    scenario 'Votes' do
      debate = create(:debate)
      create(:vote, votable: debate)

      proposal = create(:proposal)
      2.times { create(:vote, votable: proposal) }

      comment = create(:comment)
      3.times { create(:vote, votable: comment) }

      visit stats_path

      expect(page).to have_content "Votes on debates 1"
      expect(page).to have_content "Votes on proposals 2"
      expect(page).to have_content "Votes on comments 3"
      expect(page).to have_content "Total votes 6"
    end

    scenario 'Users' do
      create_list(:user, 2)
      create_list(:user, 2, :level_two)
      create(:user, :level_three)

      visit stats_path

      expect(page).to have_content "Verified users 3"
      expect(page).to have_content "Unverified users 2"
    end

  end

end
