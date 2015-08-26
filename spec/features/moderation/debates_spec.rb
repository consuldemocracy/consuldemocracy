require 'rails_helper'

feature 'Moderate debates' do

  scenario 'Hide', :js do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)

    login_as(moderator.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      click_link 'Hide'
    end

    expect(page).to have_css("#debate_#{debate.id}.faded")

    login_as(citizen)
    visit debates_path

    expect(page).to have_css('.debate', count: 0)
  end

  scenario 'Can not hide own debate' do
    moderator = create(:moderator)
    debate = create(:debate, author: moderator.user)

    login_as(moderator.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      expect(page).to_not have_link('Hide')
      expect(page).to_not have_link('Block author')
    end
  end

  feature '/moderation/ menu' do

    background do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_debates_path
      expect(page).to_not have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to have_link('Archived')

      visit moderation_debates_path(filter: 'all')
      expect(page).to_not have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to have_link('Archived')

      visit moderation_debates_path(filter: 'pending')
      expect(page).to have_link('All')
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('Archived')

      visit moderation_debates_path(filter: 'archived')
      expect(page).to have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to_not have_link('Archived')
    end

    scenario "Filtering debates" do
      create(:debate, :flagged_as_inappropiate, title: "Pending debate")
      create(:debate, :flagged_as_inappropiate, :hidden, title: "Hidden debate")
      create(:debate, :flagged_as_inappropiate, :archived, title: "Archived debate")

      visit moderation_debates_path(filter: 'all')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Archived debate')

      visit moderation_debates_path(filter: 'pending')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to_not have_content('Archived debate')

      visit moderation_debates_path(filter: 'archived')
      expect(page).to_not have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Archived debate')
    end

    scenario "Reviewing links remember the pagination setting and the filter" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:debate, :flagged_as_inappropiate) }

      visit moderation_debates_path(filter: 'pending', page: 2)

      click_link('Archive', match: :first, exact: true)

      uri = URI.parse(current_url)
      query_params = Rack::Utils.parse_nested_query(uri.query).symbolize_keys

      expect(query_params[:filter]).to eq('pending')
      expect(query_params[:page]).to eq('2')
    end

    feature 'A flagged debate exists' do

      background do
        @debate = create(:debate, :flagged_as_inappropiate, title: 'spammy spam', description: 'buy buy buy')
        visit moderation_debates_path
      end

      scenario 'It is displayed with the correct attributes' do
        within("#debate_#{@debate.id}") do
          expect(page).to have_link('spammy spam')
          expect(page).to have_content('buy buy buy')
          expect(page).to have_content('1')
          expect(page).to have_link('Hide')
          expect(page).to have_link('Archive')
        end
      end

      scenario 'Hiding the debate' do
        within("#debate_#{@debate.id}") do
          click_link('Hide')
        end

        expect(current_path).to eq(moderation_debates_path)
        expect(page).to_not have_selector("#debate_#{@debate.id}")

        expect(@debate.reload).to be_hidden
      end

      scenario 'Marking the debate as archived' do
        within("#debate_#{@debate.id}") do
          click_link('Archive')
        end

        expect(current_path).to eq(moderation_debates_path)

        within("#debate_#{@debate.id}") do
          expect(page).to have_content('Archived')
        end

        expect(@debate.reload).to be_archived
      end
    end
  end

end
