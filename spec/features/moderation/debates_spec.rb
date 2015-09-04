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
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('All')
      expect(page).to have_link('Ignored')

      visit moderation_debates_path(filter: 'all')
      expect(page).to_not have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to have_link('Ignored')

      visit moderation_debates_path(filter: 'pending_flag_review')
      expect(page).to have_link('All')
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('Ignored')

      visit moderation_debates_path(filter: 'with_ignored_flag')
      expect(page).to have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to_not have_link('Ignored')
    end

    scenario "Filtering debates" do
      create(:debate, :flagged, title: "Pending debate")
      create(:debate, :flagged, :hidden, title: "Hidden debate")
      create(:debate, :flagged, :with_ignored_flag, title: "Ignored debate")

      visit moderation_debates_path(filter: 'all')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Ignored debate')

      visit moderation_debates_path(filter: 'pending_flag_review')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to_not have_content('Ignored debate')

      visit moderation_debates_path(filter: 'with_ignored_flag')
      expect(page).to_not have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Ignored debate')
    end

    scenario "Reviewing links remember the pagination setting and the filter" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:debate, :flagged) }

      visit moderation_debates_path(filter: 'pending_flag_review', page: 2)

      click_link('Ignore', match: :first, exact: true)

      expect(current_url).to include('filter=pending_flag_review')
      expect(current_url).to include('page=2')
    end

    feature 'A flagged debate exists' do

      background do
        @debate = create(:debate, :flagged, title: 'spammy spam', description: 'buy buy buy')
        visit moderation_debates_path
      end

      scenario 'It is displayed with the correct attributes' do
        within("#debate_#{@debate.id}") do
          expect(page).to have_link('spammy spam')
          expect(page).to have_content('buy buy buy')
          expect(page).to have_content('1')
          expect(page).to have_link('Hide')
          expect(page).to have_link('Ignore')
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

      scenario 'Marking the debate as ignored' do
        within("#debate_#{@debate.id}") do
          click_link('Ignore')
        end

        expect(current_path).to eq(moderation_debates_path)

        click_link('All')

        within("#debate_#{@debate.id}") do
          expect(page).to have_content('Ignored')
        end

        expect(@debate.reload).to be_ignored_flag
      end
    end
  end

end
