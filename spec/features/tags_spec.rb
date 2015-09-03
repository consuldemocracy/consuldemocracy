require 'rails_helper'

feature 'Tags' do

  scenario 'Index' do
    earth = create(:debate, tag_list: 'Medio Ambiente')
    money = create(:debate, tag_list: 'Economía')

    visit debates_path

    within "#debate_#{earth.id}" do
      expect(page).to have_content "Medio Ambiente"
    end

    within "#debate_#{money.id}" do
      expect(page).to have_content "Economía"
    end
  end

  scenario 'Filtered' do
    debate1 = create(:debate, tag_list: 'Salud')
    debate2 = create(:debate, tag_list: 'Salud')
    debate3 = create(:debate, tag_list: 'Hacienda')
    debate4 = create(:debate, tag_list: 'Hacienda')

    visit debates_path
    first(:link, "Salud").click

    within("#debates") do
      expect(page).to have_css('.debate', count: 2)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).to_not have_content(debate3.title)
      expect(page).to_not have_content(debate4.title)
    end
  end

  scenario 'Show' do
    debate = create(:debate, tag_list: 'Hacienda, Economía')

    visit debate_path(debate)

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario 'Tag Cloud' do
    1.times  { create(:debate, tag_list: 'Medio Ambiente') }
    5.times  { create(:debate, tag_list: 'Corrupción') }
    5.times  { create(:debate, tag_list: 'Educación') }
    10.times { create(:debate, tag_list: 'Economía') }

    visit debates_path

    within(:css, "#tag-cloud") do
      expect(page.find("a:eq(1)")).to have_content("Economía 10")
      expect(page.find("a:eq(2)")).to have_content("Corrupción 5")
      expect(page.find("a:eq(3)")).to have_content("Educación 5")
      expect(page.find("a:eq(4)")).to have_content("Medio Ambiente 1")
    end
  end

  scenario 'Create' do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in 'debate_title', with: 'Title'
    fill_in 'debate_description', with: 'Description'
    fill_in 'debate_captcha', with: correct_captcha_text
    check 'debate_terms_of_service'

    fill_in 'debate_tag_list', with: "Impuestos, Economía, Hacienda"

    click_button 'Start a debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Economía'
    expect(page).to have_content 'Hacienda'
    expect(page).to have_content 'Impuestos'
  end

  scenario 'Update' do
    debate = create(:debate, tag_list: 'Economía')

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_selector("input[value='Economía']")

    fill_in 'debate_tag_list', with: "Economía, Hacienda"
    fill_in 'debate_captcha', with: correct_captcha_text
    click_button 'Save changes'

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
    fill_in 'debate_captcha', with: correct_captcha_text
    click_button 'Save changes'

    expect(page).to have_content 'Debate was successfully updated.'
    expect(page).to_not have_content 'Economía'
  end

end
