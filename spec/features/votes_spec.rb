require 'rails_helper'

feature 'Votes', :focus do

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

    expect(page).to have_content "Votos 2"
    
    within('#in_favor') do 
      expect(page).to have_content "50%" 
    end
    
    within('#against')  do 
      expect(page).to have_content "50%" 
    end
  end

  scenario 'Create' do
    click_link 'up'
    expect(page).to have_content "Gracias por votar"
  end

  scenario 'Update' do
    click_link 'up'
    click_link 'down'
    expect(page).to have_content "Gracias por votar"
  end

  scenario 'Trying to vote multiple times' do
    click_link 'up'
    click_link 'up'
    expect(page).to have_content "Tu voto ya ha sido registrado"
    expect(page).to have_content "Votos 1"
  end

end