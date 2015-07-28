require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user)
    @pablo = create(:user)
    @debate = create(:debate)

    login_as(@manuela)
    visit debate_path(@debate)
  end

  scenario 'Show' do
    vote = create(:vote, voter: @manuela, votable: @debate, vote_flag: true)
    vote = create(:vote, voter: @pablo, votable: @debate, vote_flag: false)

    visit debate_path(@debate)

    expect(page).to have_content "2 votes"

    within('#in_favor') do
      expect(page).to have_content "50%"
    end

    within('#against')  do
      expect(page).to have_content "50%"
    end
  end

  scenario 'Create', :js do
    find('#in_favor a').click
    
    within('#in_favor') do
      expect(page).to have_content "100%"
    end
    
    within('#against')  do
      expect(page).to have_content "0%"
    end
    
    expect(page).to have_content "1 vote"
  end

  scenario 'Update', :js do
    find('#in_favor a').click
    find('#against a').click

    within('#in_favor') do
      expect(page).to have_content "0%"
    end

    within('#against')  do
      expect(page).to have_content "100%"
    end

    expect(page).to have_content "1 vote"
  end

  scenario 'Trying to vote multiple times', :js do
    find('#in_favor a').click
    find('#in_favor a').click
    
    within('#in_favor') do
      expect(page).to have_content "100%"
    end

    within('#against')  do
      expect(page).to have_content "0%"
    end

    expect(page).to have_content "1 vote"
  end

end