require 'rails_helper'

feature 'Debates' do

  scenario 'Index' do
    3.times { create(:debate) }

    visit debates_path

    expect(page).to have_selector('.debate', count: 3)
    within first('.debate') do
      expect(page).to have_content "Debate title"
      expect(page).to have_content "Debate description"
      expect(page).to have_content "Por #{Debate.first.author.name}"
      expect(page).to have_content "el #{I18n.l Date.today}"
    end
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content "Debate title"
    expect(page).to have_content "Debate description"
    expect(page).to have_content "Por #{debate.author.name}"
    expect(page).to have_content "el #{I18n.l Date.today}"
  end

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Acabar con los desahucios'
    fill_in 'debate_description', with: 'Esto es un tema muy importante porque...'
    check 'debate_terms_of_service'

    click_button 'Crear Debate'

    expect(page).to have_content 'Debate creado correctamente'
    expect(page).to have_content 'Acabar con los desahucios'
    expect(page).to have_content 'Esto es un tema muy importante porque...'
    expect(page).to have_content "Por #{author.name}"
    expect(page).to have_content "el #{I18n.l Date.today}"
  end

  scenario 'Update should not be posible if logged user is not the author' do
    debate = create(:debate)
    expect(debate).to be_editable
    login_as(create(:user))

    expect {
      visit edit_debate_path(debate)
    }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario 'Update should not be posible if debate is not editable' do
    debate = create(:debate)
    vote = create(:vote, votable: debate)
    expect(debate).to_not be_editable
    login_as(debate.author)

    expect {
      visit edit_debate_path(debate)
    }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario 'Update should be posible for the author of an editable debate' do
    debate = create(:debate)
    login_as(debate.author)

    visit debate_path(debate)
    click_link 'Edit'
    fill_in 'debate_title', with: 'Dimisión Rajoy'
    fill_in 'debate_description', with: 'Podríamos...'

    click_button 'Actualizar Debate'

    expect(page).to have_content 'Debate actualizado correctamente'
    expect(page).to have_content 'Dimisión Rajoy'
    expect(page).to have_content 'Podríamos...'
  end

end
