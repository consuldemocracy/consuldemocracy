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

  scenario 'Paginated Index' do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:debate) }

    visit debates_path

    expect(page).to have_selector('#debates .debate', count: per_page)

    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).to_not have_content("3")
      click_link "Next"
    end

    expect(page).to have_selector('#debates .debate', count: 2)
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content debate.title
    expect(page).to have_content "Debate description"
    expect(page).to have_content debate.author.name
    expect(page).to have_content I18n.l(debate.created_at.to_date)
    expect(page).to have_selector(avatar(debate.author.name))

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

    click_button 'Start a debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Acabar con los desahucios'
    expect(page).to have_content 'Esto es un tema muy importante porque...'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Debate.last.created_at.to_date)
  end

  scenario 'Captcha is required for debate creation' do
    login_as(create(:user))

    visit new_debate_path
    fill_in 'debate_title', with: "Great title"
    fill_in 'debate_description', with: 'Very important issue...'
    fill_in 'debate_captcha', with: "wrongText!"
    check 'debate_terms_of_service'

    click_button "Start a debate"

    expect(page).to_not have_content "Debate was successfully created."
    expect(page).to have_content "1 error"

    fill_in 'debate_captcha', with: correct_captcha_text
    click_button "Start a debate"

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

    click_button "Start a debate"

    expect(page).to_not have_content "Debate was successfully created."
    expect(page).to have_content "1 error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  scenario 'Errors on create' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    click_button 'Start a debate'
    expect(page).to have_content error_message
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'debate_captcha', with: correct_captcha_text
    check 'debate_terms_of_service'

    click_button 'Start a debate'

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

      click_button 'Start a debate'

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

      click_button 'Start a debate'

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
    create(:vote, votable: debate)
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

    click_button "Save changes"

    expect(page).to have_content "Debate was successfully updated."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's..."
  end

  scenario 'Errors on update' do
    debate = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    fill_in 'debate_title', with: ""
    click_button "Save changes"

    expect(page).to have_content error_message
  end

  scenario 'Captcha is required to update a debate' do
    debate = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: "New title"
    fill_in 'debate_captcha', with: "wrong!"
    click_button "Save changes"

    expect(page).to_not have_content "Debate was successfully updated."
    expect(page).to have_content "1 error"

    fill_in 'debate_captcha', with: correct_captcha_text
    click_button "Save changes"

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
    click_button "Save changes"

    expect(page).to_not have_content "Debate was successfully updated."
    expect(page).to have_content "1 error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  describe 'Limiting tags shown' do
    tags = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]
    let(:all_tags) { tags }
    let(:debate)   { create :debate, tag_list: all_tags }

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
      create :debate, tag_list: tag_list

      visit debates_path

      within('.debate .tags') do
        tag_list.each do |tag|
          expect(page).to have_content tag
        end
        expect(page).not_to have_content '+'
      end
    end
  end

  scenario "Flagging", :js do
    user = create(:user)
    debate = create(:debate)

    login_as(user)
    visit debate_path(debate)

    within "#debate_#{debate.id}" do
      page.find("#flag-expand-debate-#{debate.id}").click
      page.find("#flag-debate-#{debate.id}").click

      expect(page).to have_css("#unflag-expand-debate-#{debate.id}")
    end

    expect(Flag.flagged?(user, debate)).to be
  end

  scenario "Unflagging", :js do
    user = create(:user)
    debate = create(:debate)
    Flag.flag(user, debate)

    login_as(user)
    visit debate_path(debate)

    within "#debate_#{debate.id}" do
      page.find("#unflag-expand-debate-#{debate.id}").click
      page.find("#unflag-debate-#{debate.id}").click

      expect(page).to have_css("#flag-expand-debate-#{debate.id}")
    end

    expect(Flag.flagged?(user, debate)).to_not be
  end

  feature 'Debate index order filters', :js do

    before do
      @most_voted_debate  = create(:debate)
      @most_liked_debate  = create(:debate)
      @most_recent_debate = create(:debate)
      create_list(:vote, 2, votable: @most_liked_debate)
      create_list(:vote, 2, votable: @most_voted_debate, vote_flag: false)
      create(:vote, votable: @most_voted_debate)
    end

    scenario 'Default order is created_at' do
      visit debates_path

      expect(page).to have_select('order-selector', selected: 'newest')
      expect(@most_recent_debate.title).to appear_before(@most_liked_debate.title)
    end

    scenario 'Debates are ordered by most voted' do
      visit debates_path

      select 'most voted', from: 'order-selector'
      expect(page).to have_select('order-selector', selected: 'most voted')
      expect(find("#debates .debate", match: :first)).to have_content(@most_voted_debate.title)

      expect(current_url).to include('order=total_votes')
      expect(@most_voted_debate.title).to appear_before(@most_liked_debate.title)
      expect(@most_liked_debate.title).to appear_before(@most_recent_debate.title)
    end

    scenario 'Debates are ordered by best rated' do
      visit debates_path

      select 'best rated', from: 'order-selector'
      expect(page).to have_select('order-selector', selected: 'best rated')
      expect(find("#debates .debate", match: :first)).to have_content(@most_liked_debate.title)

      expect(current_url).to include('order=likes')
      expect(@most_liked_debate.title).to appear_before(@most_voted_debate.title)
      expect(@most_voted_debate.title).to appear_before(@most_recent_debate.title)
    end

    scenario 'Debates are ordered by newest' do
      visit debates_path

      select 'most voted', from: 'order-selector'
      expect(find("#debates .debate", match: :first)).to have_content(@most_voted_debate.title)

      select 'newest', from: 'order-selector'
      expect(page).to have_select('order-selector', selected: 'newest')
      expect(find("#debates .debate", match: :first)).to have_content(@most_recent_debate.title)

      expect(current_url).to include('order=created_at')
      expect(@most_recent_debate.title).to appear_before(@most_liked_debate.title)
      expect(@most_liked_debate.title).to appear_before(@most_voted_debate.title)
    end
  end

  feature 'Debates can be filtered by tags', :js do
    let!(:debate1) { create(:debate, tag_list: ["Deporte", "Corrupción"]) }
    let!(:debate2) { create(:debate, tag_list: ["Deporte", "Fiestas populares"]) }
    let!(:debate3) { create(:debate, tag_list: ["Corrupción", "Fiestas populares"]) }

    scenario 'By default no tag filter is applied' do
      visit debates_path

      expect(page).to have_content('Filter by topic')
      expect(page).not_to have_content('with the topic')
      expect(page).to have_selector('#debates .debate', count: 3)
    end

    scenario 'Debates are filtered by single tag' do
      visit debates_path

      select('Deporte', from: 'tag-filter')

      expect(page).not_to have_content('Filter by topic')
      expect(page).not_to have_select('tag-filter')
      expect(page).to have_content('with the topic')
      expect(current_url).to include('tag=Deporte')

      expect(page).to have_selector('#debates .debate', count: 2)
      expect(page).to_not have_content(debate3.title)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
    end
  end
end
