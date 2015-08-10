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

  scenario 'tagging using dangerous strings' do

    author = create(:user)
    login_as(author)

    visit new_debate_path

    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: 'A test'
    fill_in 'debate_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'
    fill_in 'debate_captcha', with: SimpleCaptcha::SimpleCaptchaData.first.value
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'user_id1'
    expect(page).to have_content 'a3'
    expect(page).to have_content 'scriptalert("hey");script'
    expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
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
    edit_debate_path(debate)
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

    click_button "Update Debate"

    expect(page).to have_content "Debate was successfully updated."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's..."
  end

end
