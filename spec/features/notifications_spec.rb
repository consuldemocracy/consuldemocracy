require 'rails_helper'

feature "Notifications" do
  let(:admin_user) { create :user }
  let(:administrator) do
    create(:administrator, user: admin_user)
    admin_user
  end
  let(:author) { create :user }
  let(:user) { create :user }
  let(:debate) { create :debate, author: author }
  let(:proposal) { create :proposal, author: author }
  let(:process) { create :legislation_process, :in_debate_phase }
  let(:legislation_question) { create(:legislation_question, process: process, author: administrator) }
  let(:legislation_annotation) { create(:legislation_annotation, author: author) }

  let(:topic) do
    proposal = create(:proposal)
    community = proposal.community
    create(:topic, community: community, author: author)
  end

  scenario "User commented on my debate", :js do
    create(:notification, notifiable: debate, user: author)
    login_as author
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1

    expect(page).to have_content "Someone commented on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "User commented on my legislation question", :js do
    create(:notification, notifiable: legislation_question, user: administrator)
    login_as administrator
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1

    expect(page).to have_content "Someone commented on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "User commented on my topic", :js do
    create(:notification, notifiable: topic, user: author)
    login_as author
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1

    expect(page).to have_content "Someone commented on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Multiple comments on my proposal", :js do
    login_as user
    visit proposal_path proposal

    fill_in "comment-body-proposal_#{proposal.id}", with: "I agree"
    click_button "Publish comment"
    within "#comments" do
      expect(page).to have_content "I agree"
    end

    logout
    login_as create(:user)
    visit proposal_path proposal

    fill_in "comment-body-proposal_#{proposal.id}", with: "I disagree"
    click_button "Publish comment"
    within "#comments" do
      expect(page).to have_content "I disagree"
    end

    logout
    login_as author
    visit root_path
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1

    expect(page).to have_content "There are 2 new comments on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "User replied to my comment", :js do
    comment = create :comment, commentable: debate, user: author
    login_as user
    visit debate_path debate

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: "I replied to your comment"
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "I replied to your comment"
    end

    logout

    login_as author
    visit root_path
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "Someone replied to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Multiple replies to my comment", :js do
    comment = create :comment, commentable: debate, user: author
    3.times do |n|
      login_as create(:user)
      visit debate_path debate

      within("#comment_#{comment.id}_reply") { click_link "Reply" }
      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "comment-body-comment_#{comment.id}", with: "Reply number #{n}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Reply number #{n}"
      end
      logout
    end

    login_as author
    visit root_path
    visit root_path

    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "There are 3 new replies to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Author commented on his own debate", :js do
    login_as author
    visit debate_path debate

    fill_in "comment-body-debate_#{debate.id}", with: "I commented on my own debate"
    click_button "Publish comment"
    within "#comments" do
      expect(page).to have_content "I commented on my own debate"
    end

    find(".icon-no-notification").click
    expect(page).to have_css ".notification", count: 0
  end

  scenario "Author replied to his own comment", :js do
    comment = create :comment, commentable: debate, user: author
    login_as author
    visit debate_path debate

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: "I replied to my own comment"
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "I replied to my own comment"
    end

    find(".icon-no-notification")

    visit notifications_path
    expect(page).to have_css ".notification", count: 0
  end

  context "Proposal notification" do

    scenario "Voters should receive a notification", :js do
      author = create(:user)

      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      proposal = create(:proposal, author: author)

      create(:vote, voter: user1, votable: proposal, vote_flag: true)
      create(:vote, voter: user2, votable: proposal, vote_flag: true)

      login_as(author)
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
      fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      logout
      login_as user1
      visit root_path
      visit root_path

      find(".icon-notification").click

      notification_for_user1 = Notification.where(user: user1).first
      expect(page).to have_css ".notification", count: 1
      expect(page).to have_content "There is one new notification on #{proposal.title}"
      expect(page).to have_xpath "//a[@href='#{notification_path(notification_for_user1)}']"

      logout
      login_as user2
      visit root_path
      visit root_path

      find(".icon-notification").click

      notification_for_user2 = Notification.where(user: user2).first
      expect(page).to have_css ".notification", count: 1
      expect(page).to have_content "There is one new notification on #{proposal.title}"
      expect(page).to have_xpath "//a[@href='#{notification_path(notification_for_user2)}']"

      logout
      login_as user3
      visit root_path
      visit root_path

      find(".icon-no-notification").click

      expect(page).to have_css ".notification", count: 0
    end

    scenario "Followers should receive a notification", :js do
      author = create(:user)

      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      proposal = create(:proposal, author: author)

      create(:follow, :followed_proposal, user: user1, followable: proposal)
      create(:follow, :followed_proposal, user: user2, followable: proposal)

      login_as author.reload
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
      fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      logout
      login_as user1.reload
      visit root_path

      find(".icon-notification").click

      notification_for_user1 = Notification.where(user: user1).first
      expect(page).to have_css ".notification", count: 1
      expect(page).to have_content "There is one new notification on #{proposal.title}"
      expect(page).to have_xpath "//a[@href='#{notification_path(notification_for_user1)}']"

      logout
      login_as user2.reload
      visit root_path

      find(".icon-notification").click

      notification_for_user2 = Notification.where(user: user2).first
      expect(page).to have_css ".notification", count: 1
      expect(page).to have_content "There is one new notification on #{proposal.title}"
      expect(page).to have_xpath "//a[@href='#{notification_path(notification_for_user2)}']"

      logout
      login_as user3.reload
      visit root_path

      find(".icon-no-notification").click

      expect(page).to have_css ".notification", count: 0
    end

    pending "group notifications for the same proposal"

  end

  context "mark as read" do

    scenario "mark a single notification as read" do
      user = create :user
      notification = create :notification, user: user

      login_as user
      visit notifications_path

      expect(page).to have_css ".notification", count: 1

      first(".notification a").click
      visit notifications_path

      expect(page).to have_css ".notification", count: 0
    end

    scenario "mark all notifications as read" do
      user = create :user
      2.times { create :notification, user: user }

      login_as user
      visit notifications_path

      expect(page).to have_css ".notification", count: 2
      click_link "Mark all as read"

      expect(page).to have_css ".notification", count: 0
      expect(current_path).to eq(notifications_path)
    end

  end

  scenario "no notifications" do
    login_as user
    visit notifications_path

    expect(page).to have_content "You don't have new notifications"
  end

end
