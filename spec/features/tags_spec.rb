require 'rails_helper'

feature 'Tags' do

  scenario 'Index' do
    earth = create(:debate, tag_list: 'Medio Ambiente')
    money = create(:debate, tag_list: 'Economía')

    visit debates_path

    within "#debate-#{earth.id}" do
      expect(page).to have_content "Medio Ambiente"
    end

    within "#debate-#{money.id}" do
      expect(page).to have_content "Economía"
    end
  end

  scenario 'Filtered' do
    2.times { create(:debate, tag_list: 'Salud') }
    2.times { create(:debate, tag_list: 'Hacienda') }

    visit debates_path
    first(:link, "Salud").click

    within('#debates') do
      expect(page).to have_css('.debate', count: 2)
      expect(page).to have_content('Salud')
      expect(page).to_not have_content('Hacienda')
    end
  end

  scenario 'Show' do
    debate = create(:debate, tag_list: 'Hacienda, Economía')

    visit debate_path(debate)

    expect(page).to have_content "Economía, Hacienda"
  end

  scenario 'Tag Cloud' do
    1.times  { create(:debate, tag_list: 'Medio Ambiente') }
    5.times  { create(:debate, tag_list: 'Corrupción') }
    10.times { create(:debate, tag_list: 'Economía') }

    visit debates_path

    within "#tag-cloud" do
      expect(page).to have_css(".s", text: "Medio Ambiente(1)")
      expect(page).to have_css(".m", text: "Corrupción(5)")
      expect(page).to have_css(".l", text: "Economía(10)")
    end
  end

  scenario 'Create' do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in 'debate_title', with: 'Title'
    fill_in 'debate_description', with: 'Description'
    check 'debate_terms_of_service'

    fill_in 'debate_tag_list', with: "Impuestos, Economía, Hacienda"

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Economía, Hacienda, Impuestos'
  end

  scenario 'Update' do
    debate = create(:debate, tag_list: 'Economía')

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_selector("input[value='Economía']")

    fill_in 'debate_tag_list', with: "Economía, Hacienda"
    click_button 'Update Debate'

    expect(page).to have_content 'Debate was successfully updated.'
    within('.tags') do
      expect(page).to have_css('a', text: 'Economía')
      expect(page).to have_css('a', text: 'Hacienda')
    end
  end

  scenario 'Delete' do
    debate = create(:debate, tag_list: 'Economía')

    login_as(debate.author)
    visit edit_debate_path(debate)

    fill_in 'debate_tag_list', with: ""
    click_button 'Update Debate'

    expect(page).to have_content 'Debate was successfully updated.'
    expect(page).to_not have_content 'Economía'
  end

end