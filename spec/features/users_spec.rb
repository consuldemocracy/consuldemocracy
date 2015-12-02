require 'rails_helper'

feature 'Users' do

  feature 'Show (public page)' do

    background do
      @user = create(:user)
      1.times {create(:debate, author: @user)}
      2.times {create(:proposal, author: @user)}
      3.times {create(:comment, user: @user)}

      visit user_path(@user)
    end

    scenario 'shows user public activity' do
      expect(page).to have_content('1 Debate')
      expect(page).to have_content('2 Proposals')
      expect(page).to have_content('3 Comments')
    end

    scenario 'shows only items where user has activity' do
      @user.proposals.destroy_all

      expect(page).to_not have_content('0 Proposals')
      expect(page).to have_content('1 Debate')
      expect(page).to have_content('3 Comments')
    end

    scenario 'default filter is proposals' do
      @user.proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      @user.debates.each do |debate|
        expect(page).to_not have_content(debate.title)
      end

      @user.comments.each do |comment|
        expect(page).to_not have_content(comment.body)
      end
    end

    scenario 'shows debates by default if user has no proposals' do
      @user.proposals.destroy_all
      visit user_path(@user)

      expect(page).to have_content(@user.debates.first.title)
    end

    scenario 'shows comments by default if user has no proposals nor debates' do
      @user.proposals.destroy_all
      @user.debates.destroy_all
      visit user_path(@user)

      @user.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end
    end

    scenario 'filters' do
      click_link '1 Debate'

      @user.debates.each do |debate|
        expect(page).to have_content(debate.title)
      end

      @user.proposals.each do |proposal|
        expect(page).to_not have_content(proposal.title)
      end

      @user.comments.each do |comment|
        expect(page).to_not have_content(comment.body)
      end

      click_link '3 Comments'

      @user.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end

      @user.proposals.each do |proposal|
        expect(page).to_not have_content(proposal.title)
      end

      @user.debates.each do |debate|
        expect(page).to_not have_content(debate.title)
      end

      click_link '2 Proposals'

      @user.proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      @user.comments.each do |comment|
        expect(page).to_not have_content(comment.body)
      end

      @user.debates.each do |debate|
        expect(page).to_not have_content(debate.title)
      end
    end

  end

  feature 'Public activity' do
    background do
      @user = create(:user)
    end

    scenario 'visible by default' do
      visit user_path(@user)

      expect(page).to have_content(@user.username)
      expect(page).to_not have_content('activity list private')
    end

    scenario 'user can hide public page' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      visit user_path(@user)
      expect(page).to have_content('activity list private')
    end

    scenario 'is always visible for the owner' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    scenario 'is always visible for admins' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      login_as(create(:administrator).user)
      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    scenario 'is always visible for moderators' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      login_as(create(:moderator).user)
      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    feature 'User email' do

      background do
        @user = create(:user)
      end

      scenario 'is not shown if no user logged in' do
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      scenario 'is not shown if logged in user is a regular user' do
        login_as(create(:user))
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      scenario 'is not shown if logged in user is moderator' do
        login_as(create(:moderator).user)
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      scenario 'is shown if logged in user is admin' do
        login_as(create(:administrator).user)
        visit user_path(@user)
        expect(page).to have_content(@user.email)
      end

    end
  end

  feature 'Special comments' do

    scenario 'comments posted as moderator are not visible in user activity' do
      moderator = create(:administrator).user
      comment = create(:comment, user: moderator)
      moderator_comment = create(:comment, user: moderator, moderator_id: moderator.id)

      visit user_path(moderator)
      expect(page).to have_content("1 Comment")
      expect(page).to have_content(comment.body)
      expect(page).to_not have_content(moderator_comment.body)
    end

    scenario 'comments posted as admin are not visible in user activity' do
      admin = create(:administrator).user
      comment = create(:comment, user: admin)
      admin_comment = create(:comment, user: admin, administrator_id: admin.id)

      visit user_path(admin)
      expect(page).to have_content(comment.body)
      expect(page).to_not have_content(admin_comment.body)
    end
  end

end