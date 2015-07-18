require 'rails_helper'

feature 'Debates' do
  
  scenario 'Index' do
    3.times { create(:debate) }

    visit debates_path

    expect(page).to have_selector('.debate', count: 3)
    within first('.debate') do
      expect(page).to have_content "Debate title"
      expect(page).to have_content "Debate description"
      expect(page).to have_content "Creado el: #{I18n.l Date.today}"
      expect(page).to have_content "por: #{Debate.first.author.name}"
    end
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content "Debate title"
    expect(page).to have_content "Debate description"
    expect(page).to have_content "Creado el: #{I18n.l Date.today}"
    expect(page).to have_content "por: #{debate.author.name}"
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
    expect(page).to have_content "Creado el: #{I18n.l Date.today}"
    expect(page).to have_content "por: #{author.name}"
  end

  scenario 'Update' do
    debate = create(:debate)

    visit edit_debate_path(debate)
    fill_in 'debate_title', with: 'Dimisión Rajoy'
    fill_in 'debate_description', with: 'Podríamos...'
    
    click_button 'Actualizar Debate'

    expect(page).to have_content 'Debate actualizado correctamente'
    expect(page).to have_content 'Dimisión Rajoy'
    expect(page).to have_content 'Podríamos...'
  end

end
