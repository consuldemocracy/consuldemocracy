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

    earth2 = create(:medida, tag_list: 'Medio Ambiente 2')
    money2 = create(:medida, tag_list: 'Economía 2')

    visit medidas_path

    within "#medida_#{earth2.id}" do
      expect(page).to have_content "Medio Ambiente 2"
    end

    within "#medida_#{money2.id}" do
      expect(page).to have_content "Economía 2"
    end
  end

  scenario 'Filtered' do
    debate1 = create(:debate, tag_list: 'Salud')
    debate2 = create(:debate, tag_list: 'salud')
    debate3 = create(:debate, tag_list: 'Hacienda')
    debate4 = create(:debate, tag_list: 'Hacienda')

    visit debates_path
    first(:link, 'Salud').click

    within("#debates") do
      expect(page).to have_css('.debate', count: 2)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).to_not have_content(debate3.title)
      expect(page).to_not have_content(debate4.title)
    end

    visit debates_path(tag: 'salud')

    within("#debates") do
      expect(page).to have_css('.debate', count: 2)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).to_not have_content(debate3.title)
      expect(page).to_not have_content(debate4.title)
    end
  end

  scenario 'Filtered2' do
    medida1 = create(:medida, tag_list: 'Salud')
    medida2 = create(:medida, tag_list: 'salud')
    medida3 = create(:medida, tag_list: 'Hacienda')
    medida4 = create(:medida, tag_list: 'Hacienda')

    visit medidas_path
    first(:link, 'Salud').click

    within("#medidas") do
      expect(page).to have_css('.medida', count: 2)
      expect(page).to have_content(medida1.title)
      expect(page).to have_content(medida2.title)
      expect(page).to_not have_content(medida3.title)
      expect(page).to_not have_content(medida4.title)
    end

    visit medidas_path(tag: 'salud')

    within("#medidas") do
      expect(page).to have_css('.medida', count: 2)
      expect(page).to have_content(medida1.title)
      expect(page).to have_content(medida2.title)
      expect(page).to_not have_content(medida3.title)
      expect(page).to_not have_content(medida4.title)
    end
  end

  scenario 'Show' do
    medida = create(:medida, tag_list: 'Hacienda, Economía')

    visit medida_path(medida)

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario 'Tag Cloud' do
    1.times  { create(:medida, tag_list: 'Medio Ambiente2') }
    5.times  { create(:medida, tag_list: 'Corrupción2') }
    5.times  { create(:medida, tag_list: 'Educación2') }
    10.times { create(:medida, tag_list: 'Economía2') }

    visit medidas_path

    within(:css, "#tag-cloud") do
      expect(page.find("a:eq(1)")).to have_content("Economía2 10")
      expect(page.find("a:eq(2)")).to have_content("Corrupción2 5")
      expect(page.find("a:eq(3)")).to have_content("Educación2 5")
      expect(page.find("a:eq(4)")).to have_content("Medio Ambiente2 1")
    end
  end

  scenario 'Create' do
    user = create(:user)
    login_as(user)

    visit new_medida_path
    fill_in 'medida_title', with: 'Title'
    fill_in 'medida_description', with: 'Description'
    fill_in 'medida_captcha', with: correct_captcha_text
    check 'medida_terms_of_service'

    fill_in 'medida_tag_list', with: "Impuestos, Economía, Hacienda"

    click_button 'Start a medida'

    expect(page).to have_content 'Medida was successfully created.'
    expect(page).to have_content 'Economía'
    expect(page).to have_content 'Hacienda'
    expect(page).to have_content 'Impuestos'
  end

  scenario 'Update' do
    medida = create(:medida, tag_list: 'Economía')

    login_as(medida.author)
    visit edit_medida_path(medida)

    expect(page).to have_selector("input[value='Economía']")

    fill_in 'medida_tag_list', with: "Economía, Hacienda"
    fill_in 'medida_captcha', with: correct_captcha_text
    click_button 'Save changes'

    expect(page).to have_content 'Medida was successfully updated.'
    within('.tags') do
      expect(page).to have_css('a', text: 'Economía')
      expect(page).to have_css('a', text: 'Hacienda')
    end
  end

  scenario 'Delete' do
    medida = create(:medida, tag_list: 'Economía')

    login_as(medida.author)
    visit edit_medida_path(medida)

    fill_in 'medida_tag_list', with: ""
    fill_in 'medida_captcha', with: correct_captcha_text
    click_button 'Save changes'

    expect(page).to have_content 'Medida was successfully updated.'
    expect(page).to_not have_content 'Economía'
  end

end
