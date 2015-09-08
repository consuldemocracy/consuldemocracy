require 'rails_helper'

feature 'Moderate in bulk' do

  feature "When a debate has been selected for moderation" do
    background do
      moderator = create(:moderator)
      @debate = create(:debate)

      login_as(moderator.user)
      visit moderation_bulk_path

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
  end

end
