require 'rails_helper'

feature "Notifications" do
  let(:author) { create :user }
  let(:user) { create :user }
  let(:debate) { create :debate, author: author }

  scenario "User commented on my debate", :js do
    login_as user
    visit debate_path debate

    fill_in "comment-body-debate_#{debate.id}", with: "I commented on your debate"
    click_button "Publish comment"
    within "#comments" do
      expect(page).to have_content "I commented on your debate"
    end

    logout
    login_as author
    visit root_path
    expect(page).to have_xpath "//a[@class='with_notifications' and @href='#{notifications_path}' and text()='Notificaciones']"

    click_link "Notificaciones"
    expect(page).to have_content user.username
    expect(page).to have_content I18n.t("comments.notifications.commented_on_your_debate")
    expect(page).to_not have_content I18n.t("comments.notifications.replied_to_your_comment")
    expect(page).to have_link debate.title, href: debate_path(debate)
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
    expect(page).to have_xpath "//a[@class='with_notifications' and @href='#{notifications_path}' and text()='Notificaciones']"

    visit notifications_path
    expect(page).to have_content user.username
    expect(page).to have_content I18n.t("comments.notifications.replied_to_your_comment")
    expect(page).to_not have_content I18n.t("comments.notifications.commented_on_your_debate")
    expect(page).to have_link debate.title, href: debate_path(debate)
  end

  scenario "Author commented on his own debate", :js do
    login_as author
    visit debate_path debate

    fill_in "comment-body-debate_#{debate.id}", with: "I commented on my own debate"
    click_button "Publish comment"
    within "#comments" do
      expect(page).to have_content "I commented on my own debate"
    end
    expect(page).to have_xpath "//a[@class='without_notifications' and @href='#{notifications_path}' and text()='Notificaciones']"

    click_link "Notificaciones"
    expect(page).to_not have_content user.username
    expect(page).to_not have_content I18n.t("comments.notifications.commented_on_your_debate")
    expect(page).to_not have_content I18n.t("comments.notifications.replied_to_your_comment")
    expect(page).to_not have_link debate.title, href: debate_path(debate)
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
    expect(page).to have_xpath "//a[@class='without_notifications' and @href='#{notifications_path}' and text()='Notificaciones']"

    visit notifications_path
    expect(page).to_not have_content user.username
    expect(page).to_not have_content I18n.t("comments.notifications.replied_to_your_comment")
    expect(page).to_not have_content I18n.t("comments.notifications.commented_on_your_debate")
    expect(page).to_not have_link debate.title, href: debate_path(debate)
  end
end
