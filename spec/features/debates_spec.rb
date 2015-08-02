require 'rails_helper'

feature 'Debates' do

  scenario 'Index' do
    3.times { create(:debate) }

    visit debates_path

    expect(page).to have_selector('.debate', count: 3)
    within first('.debate') do
      expect(page).to have_content "Debate title"
      expect(page).to have_content "Debate description"
      expect(page).to have_content Debate.first.author.name
      expect(page).to have_content I18n.l(Date.today)
    end
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content "Debate title"
    expect(page).to have_content "Debate description"
    expect(page).to have_content debate.author.name
    expect(page).to have_content I18n.l(Date.today)
  end

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Acabar con los desahucios'
    fill_in 'debate_description', with: 'Esto es un tema muy importante porque...'
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Acabar con los desahucios'
    expect(page).to have_content 'Esto es un tema muy importante porque...'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Date.today)
  end

  scenario 'JS injection is sanitized' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: 'This is <script>alert("an attack");</script>'
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'A test'
    expect(page).to have_content 'This is alert("an attack");'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
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
    fill_in 'debate_title', with: "End child poverty"
    fill_in 'debate_description', with: "Let's..."

    click_button "Update Debate"

    expect(page).to have_content "Debate was successfully updated."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's..."
  end

end
