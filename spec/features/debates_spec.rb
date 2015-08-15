require 'rails_helper'

feature 'Debates' do

  scenario 'Index' do
    debates = [create(:debate), create(:debate), create(:debate)]

    visit debates_path

    expect(page).to have_selector('#debates .debate', count: 3)
    debates.each do |debate|
      within('#debates') do
        expect(page).to have_content debate.title
        expect(page).to have_css("a[href='#{debate_path(debate)}']", text: debate.description)
      end
    end
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content debate.title
    expect(page).to have_content "Debate description"
    expect(page).to have_content debate.author.name
    expect(page).to have_content I18n.l(Date.today)
    expect(page).to have_selector(avatar(debate.author.name), count: 1)

    within('.social-share-button') do
      expect(page.all('a').count).to be(3) # Twitter, Facebook, Google+
    end
  end

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Acabar con los desahucios'
    fill_in 'debate_description', with: 'Esto es un tema muy importante porque...'
    fill_in 'debate_captcha', with: correct_captcha_text
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Acabar con los desahucios'
    expect(page).to have_content 'Esto es un tema muy importante porque...'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Date.today)
  end

  scenario 'Captcha is required for debate creation' do
    login_as(create(:user))

    visit new_debate_path
    fill_in 'debate_title', with: "Great title"
    fill_in 'debate_description', with: 'Very important issue...'
    fill_in 'debate_captcha', with: "wrongText!"
    check 'debate_terms_of_service'

    click_button "Create Debate"

    expect(page).to_not have_content "Debate was successfully created."
    expect(page).to have_content "1 error"

    fill_in 'debate_captcha', with: correct_captcha_text
    click_button "Create Debate"

    expect(page).to have_content "Debate was successfully created."
  end

  scenario 'Failed creation goes back to new showing featured tags' do
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(create(:user))

    visit new_debate_path
    fill_in 'debate_title', with: ""
    fill_in 'debate_description', with: 'Very important issue...'
    fill_in 'debate_captcha', with: correct_captcha_text
    check 'debate_terms_of_service'

    click_button "Create Debate"

    expect(page).to_not have_content "Debate was successfully created."
    expect(page).to have_content "1 error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'debate_captcha', with: correct_captcha_text
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'A test'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
    expect(page.html).to_not include '&lt;p&gt;This is'
  end

  context 'Tagging debates' do
    let(:author) { create(:user) }

    background do
      login_as(author)
    end

    scenario 'using featured tags', :js do
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        create(:tag, :featured, name: tag_name)
      end

      visit new_debate_path

      fill_in 'debate_title', with: 'A test'
      fill_in_ckeditor 'debate_description', with: 'A test'
      fill_in 'debate_captcha', with: correct_captcha_text
      check 'debate_terms_of_service'

      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        find('.js-add-tag-link', text: tag_name).click
      end

      click_button 'Create Debate'

      expect(page).to have_content 'Debate was successfully created.'
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        expect(page).to have_content tag_name
      end
    end

    scenario 'using dangerous strings' do
      visit new_debate_path

      fill_in 'debate_title', with: 'A test'
      fill_in 'debate_description', with: 'A test'
      fill_in 'debate_captcha', with: correct_captcha_text
      check 'debate_terms_of_service'

      fill_in 'debate_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

      click_button 'Create Debate'

      expect(page).to have_content 'Debate was successfully created.'
      expect(page).to have_content 'user_id1'
      expect(page).to have_content 'a3'
      expect(page).to have_content 'scriptalert("hey");script'
      expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
    end
  end

  scenario 'Update should not be posible if logged user is not the author' do
    debate = create(:debate)
    expect(debate).to be_editable
    login_as(create(:user))

    visit edit_debate_path(debate)
    expect(current_path).to eq(root_path)
    expect(page).to have_content 'not authorized'
  end

  scenario 'Update should not be posible if debate is not editable' do
    debate = create(:debate)
    vote = create(:vote, votable: debate)
    expect(debate).to_not be_editable
    login_as(debate.author)

    visit edit_debate_path(debate)

    expect(current_path).to eq(root_path)
    expect(page).to have_content 'not authorized'
  end

  scenario 'Update should be posible for the author of an editable debate' do
    debate = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: "End child poverty"
    fill_in 'debate_description', with: "Let's..."
    fill_in 'debate_captcha', with: correct_captcha_text

    click_button "Update Debate"

    expect(page).to have_content "Debate was successfully updated."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's..."
  end

  scenario 'Captcha is required to update a debate' do
    debate       = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: "New title"
    fill_in 'debate_captcha', with: "wrong!"
    click_button "Update Debate"

    expect(page).to_not have_content "Debate was successfully updated."
    expect(page).to have_content "1 error"

    fill_in 'debate_captcha', with: correct_captcha_text
    click_button "Update Debate"

    expect(page).to have_content "Debate was successfully updated."
  end

  scenario 'Failed update goes back to edit showing featured tags' do
    debate       = create(:debate)
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: ""
    fill_in 'debate_captcha', with: correct_captcha_text
    click_button "Update Debate"

    expect(page).to_not have_content "Debate was successfully updated."
    expect(page).to have_content "1 error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  describe 'Limiting tags shown' do
    let(:all_tags) {
      ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]
    }
    let(:debate) {
      create :debate, tag_list: all_tags
    }

    scenario 'Index page shows up to 5 tags per debate' do
      debate
      visible_tags = ["Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]

      visit debates_path

      within('.debate .tags') do
        visible_tags.each do |tag|
          expect(page).to have_content tag
        end
        expect(page).to have_content '2+'
      end
    end

    scenario 'Index page shows 3 tags with no plus link' do
      tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
      debate = create :debate, tag_list: tag_list

      visit debates_path

      within('.debate .tags') do
        tag_list.each do |tag|
          expect(page).to have_content tag
        end
        expect(page).not_to have_content '+'
      end
    end

    scenario 'Debate#show shows the full tag list' do
      visit debate_path(debate)

      within("#debate-#{debate.id}") do
        all_tags.each do |tag|
          expect(page).to have_content tag
        end
      end
    end
  end
end
