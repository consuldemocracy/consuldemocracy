require 'rails_helper'

feature 'Moderate debates' do

  scenario 'Disabled with a feature flag' do
    Setting['feature.debates'] = nil
    moderator = create(:moderator)
    login_as(moderator.user)

    expect{ visit moderation_debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting['feature.debates'] = true
  end

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

  feature '/moderation/ screen' do

    background do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    feature 'moderate in bulk' do
      feature "When a debate has been selected for moderation" do
        background do
          @debate = create(:debate)
          visit moderation_debates_path
          within('.menu.simple') do
            click_link "All"
          end

          within("#debate_#{@debate.id}") do
            check "debate_#{@debate.id}_check"
          end

          expect(page).to_not have_css("debate_#{@debate.id}")
        end

        scenario 'Hide the debate' do
          click_on "Hide debates"
          expect(page).to_not have_css("debate_#{@debate.id}")
          expect(@debate.reload).to be_hidden
          expect(@debate.author).to_not be_hidden
        end

        scenario 'Block the author' do
          click_on "Block authors"
          expect(page).to_not have_css("debate_#{@debate.id}")
          expect(@debate.reload).to be_hidden
          expect(@debate.author).to be_hidden
        end

        scenario 'Ignore the debate' do
          click_on "Mark as viewed"
          expect(page).to_not have_css("debate_#{@debate.id}")
          expect(@debate.reload).to be_ignored_flag
          expect(@debate.reload).to_not be_hidden
          expect(@debate.author).to_not be_hidden
        end
      end

      scenario "select all/none", :js do
        create_list(:debate, 2)

        visit moderation_debates_path

        within('.js-check') { click_on 'All' }

        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).to be_checked
        end

        within('.js-check') { click_on 'None' }

        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).to_not be_checked
        end
      end

      scenario "remembering page, filter and order" do
        create_list(:debate, 52)

        visit moderation_debates_path(filter: 'all', page: '2', order: 'created_at')

        click_on "Mark as viewed"

        expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

        expect(current_url).to include('filter=all')
        expect(current_url).to include('page=2')
        expect(current_url).to include('order=created_at')
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_debates_path
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('All')
      expect(page).to have_link('Marked as viewed')

      visit moderation_debates_path(filter: 'all')
      within('.menu.simple') do
        expect(page).to_not have_link('All')
        expect(page).to have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_debates_path(filter: 'pending_flag_review')
      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).to_not have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_debates_path(filter: 'with_ignored_flag')
      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).to have_link('Pending')
        expect(page).to_not have_link('Marked as viewed')
      end
    end

    scenario "Filtering debates" do
      create(:debate, title: "Regular debate")
      create(:debate, :flagged, title: "Pending debate")
      create(:debate, :hidden, title: "Hidden debate")
      create(:debate, :flagged, :with_ignored_flag, title: "Ignored debate")

      visit moderation_debates_path(filter: 'all')
      expect(page).to have_content('Regular debate')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Ignored debate')

      visit moderation_debates_path(filter: 'pending_flag_review')
      expect(page).to_not have_content('Regular debate')
      expect(page).to have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to_not have_content('Ignored debate')

      visit moderation_debates_path(filter: 'with_ignored_flag')
      expect(page).to_not have_content('Regular debate')
      expect(page).to_not have_content('Pending debate')
      expect(page).to_not have_content('Hidden debate')
      expect(page).to have_content('Ignored debate')
    end

    scenario "sorting debates" do
      create(:debate, title: "Flagged debate", created_at: Time.current - 1.day, flags_count: 5)
      create(:debate, title: "Flagged newer debate", created_at: Time.current - 12.hours, flags_count: 3)
      create(:debate, title: "Newer debate", created_at: Time.current)

      visit moderation_debates_path(order: 'created_at')

      expect("Flagged newer debate").to appear_before("Flagged debate")

      visit moderation_debates_path(order: 'flags')

      expect("Flagged debate").to appear_before("Flagged newer debate")

      visit moderation_debates_path(filter: 'all', order: 'created_at')

      expect("Newer debate").to appear_before("Flagged newer debate")
      expect("Flagged newer debate").to appear_before("Flagged debate")

      visit moderation_debates_path(filter: 'all', order: 'flags')

      expect("Flagged debate").to appear_before("Flagged newer debate")
      expect("Flagged newer debate").to appear_before("Newer debate")
    end
  end
end
