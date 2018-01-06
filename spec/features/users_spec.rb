require 'rails_helper'

describe 'Users' do

  describe 'Show (public page)' do

    before do
      @user = create(:user)
      1.times {create(:debate, author: @user)}
      2.times {create(:proposal, author: @user)}
      3.times {create(:budget_investment, author: @user)}
      4.times {create(:comment, user: @user)}

      visit user_path(@user)
    end

    it 'shows user public activity' do
      expect(page).to have_content('1 Debate')
      expect(page).to have_content('2 Proposals')
      expect(page).to have_content('3 Investments')
      expect(page).to have_content('4 Comments')
    end

    it 'shows only items where user has activity' do
      @user.proposals.destroy_all

      expect(page).to_not have_content('0 Proposals')
      expect(page).to have_content('1 Debate')
      expect(page).to have_content('3 Investments')
      expect(page).to have_content('4 Comments')
    end

    it 'default filter is proposals' do
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

    it 'shows debates by default if user has no proposals' do
      @user.proposals.destroy_all
      visit user_path(@user)

      expect(page).to have_content(@user.debates.first.title)
    end

    it 'shows investments by default if user has no proposals nor debates' do
      @user.proposals.destroy_all
      @user.debates.destroy_all
      visit user_path(@user)

      expect(page).to have_content(@user.budget_investments.first.title)
    end

    it 'shows comments by default if user has no proposals nor debates nor investments' do
      @user.proposals.destroy_all
      @user.debates.destroy_all
      @user.budget_investments.destroy_all
      visit user_path(@user)

      @user.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end
    end

    it 'filters' do
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

      click_link '4 Comments'

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

  describe 'Public activity' do
    before do
      @user = create(:user)
    end

    it 'visible by default' do
      visit user_path(@user)

      expect(page).to have_content(@user.username)
      expect(page).to_not have_content('activity list private')
    end

    it 'user can hide public page' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      visit user_path(@user)
      expect(page).to have_content('activity list private')
    end

    it 'is always visible for the owner' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    it 'is always visible for admins' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      login_as(create(:administrator).user)
      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    it 'is always visible for moderators' do
      login_as(@user)
      visit account_path

      uncheck 'account_public_activity'
      click_button 'Save changes'

      logout

      login_as(create(:moderator).user)
      visit user_path(@user)
      expect(page).to_not have_content('activity list private')
    end

    describe 'User email' do

      before do
        @user = create(:user)
      end

      it 'is not shown if no user logged in' do
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      it 'is not shown if logged in user is a regular user' do
        login_as(create(:user))
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      it 'is not shown if logged in user is moderator' do
        login_as(create(:moderator).user)
        visit user_path(@user)
        expect(page).to_not have_content(@user.email)
      end

      it 'is shown if logged in user is admin' do
        login_as(create(:administrator).user)
        visit user_path(@user)
        expect(page).to have_content(@user.email)
      end

    end

  end

  describe 'Public interests' do
    before do
      @user = create(:user)
    end

    it 'Display interests' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      login_as(@user)
      visit account_path

      check 'account_public_interests'
      click_button 'Save changes'

      logout

      visit user_path(@user)
      expect(page).to have_content("Sport")
    end

    it 'Not display interests when proposal has been destroyed' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)
      proposal.destroy

      login_as(@user)
      visit account_path

      check 'account_public_interests'
      click_button 'Save changes'

      logout

      visit user_path(@user)
      expect(page).not_to have_content("Sport")
    end

    it 'No visible by default' do
      visit user_path(@user)

      expect(page).to have_content(@user.username)
      expect(page).not_to have_css('#public_interests')
    end

    it 'User can display public page' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      login_as(@user)
      visit account_path

      check 'account_public_interests'
      click_button 'Save changes'

      logout

      visit user_path(@user, filter: 'follows', page: '1')

      expect(page).to have_css('#public_interests')
    end

    it 'Is always visible for the owner' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      login_as(@user)
      visit account_path

      uncheck 'account_public_interests'
      click_button 'Save changes'

      visit user_path(@user, filter: 'follows', page: '1')
      expect(page).to have_css('#public_interests')
    end

    it 'Is always visible for admins' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      login_as(@user)
      visit account_path

      uncheck 'account_public_interests'
      click_button 'Save changes'

      logout

      login_as(create(:administrator).user)
      visit user_path(@user, filter: 'follows', page: '1')
      expect(page).to have_css('#public_interests')
    end

    it 'Is always visible for moderators' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      login_as(@user)
      visit account_path

      uncheck 'account_public_interests'
      click_button 'Save changes'

      logout

      login_as(create(:moderator).user)
      visit user_path(@user, filter: 'follows', page: '1')
      expect(page).to have_css('#public_interests')
    end

    it 'Should display generic interests title' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      @user.update(public_interests: true)
      visit user_path(@user, filter: 'follows', page: '1')

      expect(page).to have_content("Tags of elements this user follows")
    end

    it 'Should display custom interests title when user is visiting own user page' do
      proposal = create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: @user)

      @user.update(public_interests: true)
      login_as(@user)
      visit user_path(@user, filter: 'follows', page: '1')

      expect(page).to have_content("Tags of elements you follow")
    end
  end

  describe 'Special comments' do

    it 'comments posted as moderator are not visible in user activity' do
      moderator = create(:administrator).user
      comment = create(:comment, user: moderator)
      moderator_comment = create(:comment, user: moderator, moderator_id: moderator.id)

      visit user_path(moderator)
      expect(page).to have_content("1 Comment")
      expect(page).to have_content(comment.body)
      expect(page).to_not have_content(moderator_comment.body)
    end

    it 'comments posted as admin are not visible in user activity' do
      admin = create(:administrator).user
      comment = create(:comment, user: admin)
      admin_comment = create(:comment, user: admin, administrator_id: admin.id)

      visit user_path(admin)
      expect(page).to have_content(comment.body)
      expect(page).to_not have_content(admin_comment.body)
    end

    it 'shows only comments from active features' do
      user = create(:user)
      1.times {create(:comment, user: user, commentable: create(:debate))}
      2.times {create(:comment, user: user, commentable: create(:budget_investment))}
      4.times {create(:comment, user: user, commentable: create(:proposal))}

      visit user_path(user)
      expect(page).to have_content('7 Comments')

      Setting['feature.debates'] = nil
      visit user_path(user)
      expect(page).to have_content('6 Comments')

      Setting['feature.budgets'] = nil
      visit user_path(user)
      expect(page).to have_content('4 Comments')

      Setting['feature.debates'] = true
      Setting['feature.budgets'] = true
    end
  end

  describe 'Following (public page)' do

    before do
      @user = create(:user)
    end

    it 'Not display following tab when user is not following any followable' do
      visit user_path(@user)

      expect(page).not_to have_content('0 Following')
    end

    it 'Active following tab by default when follows filters selected', :js do
      proposal = create(:proposal, author: @user)
      create(:follow, followable: proposal, user: @user)

      visit user_path(@user, filter: "follows")

      expect(page).to have_selector(".activity li.active", text: "1 Following")
    end

    describe 'Proposals' do

      it 'Display following tab when user is following one proposal at least' do
        proposal = create(:proposal)
        create(:follow, followable: proposal, user: @user)

        visit user_path(@user)

        expect(page).to have_content('1 Following')
      end

      it 'Display proposal tab when user is following one proposal at least' do
        proposal = create(:proposal)
        create(:follow, followable: proposal, user: @user)

        visit user_path(@user, filter: "follows")

        expect(page).to have_link('Citizen proposals', href: "#citizen_proposals")
      end

      it 'Not display proposal tab when user is not following any proposal' do
        visit user_path(@user, filter: "follows")

        expect(page).not_to have_link('Citizen proposals', href: "#citizen_proposals")
      end

      it 'Display proposals with link to proposal' do
        proposal = create(:proposal, author: @user)
        create(:follow, followable: proposal, user: @user)
        login_as @user

        visit user_path(@user, filter: "follows")
        click_link 'Citizen proposals'

        expect(page).to have_content proposal.title
      end
    end

    describe 'Budget Investments' do

      it 'Display following tab when user is following one budget investment at least' do
        budget_investment = create(:budget_investment)
        create(:follow, followable: budget_investment, user: @user)

        visit user_path(@user)

        expect(page).to have_content('1 Following')
      end

      it 'Display budget investment tab when user is following one budget investment at least' do
        budget_investment = create(:budget_investment)
        create(:follow, followable: budget_investment, user: @user)

        visit user_path(@user, filter: "follows")

        expect(page).to have_link('Investments', href: "#investments")
      end

      it 'Not display budget investment tab when user is not following any budget investment' do
        visit user_path(@user, filter: "follows")

        expect(page).not_to have_link('Investments', href: "#investments")
      end

      it 'Display budget investment with link to budget investment' do
        user = create(:user, :level_two)
        budget_investment = create(:budget_investment, author: user)
        create(:follow, followable: budget_investment, user: user)

        visit user_path(user, filter: "follows")
        click_link 'Investments'

        expect(page).to have_link budget_investment.title
      end
    end

  end

end
