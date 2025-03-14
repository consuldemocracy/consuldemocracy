shared_examples "notifiable in-app" do |factory_name|
  let(:author) { create(:user, :verified) }
  let!(:notifiable) { create(factory_name, author: author) }

  before { create(:notification, :read, notifiable: notifiable, user: author) }

  scenario "Notification message is shown" do
    create(:notification, notifiable: notifiable, user: author)

    login_as author
    visit root_path

    expect(page).to have_link "You have a new notification"
  end

  scenario "A user commented on my notifiable" do
    notification = create(:notification, notifiable: notifiable, user: author)

    login_as author
    visit root_path

    click_link "You have a new notification"

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_link text: "Someone commented on", href: notification_path(notification)
  end

  scenario "Multiple users commented on my notifiable" do
    users = 3.times.map { create(:user, :verified) }

    users.each.with_index do |user, n|
      login_as(user)

      visit path_for(notifiable)

      fill_in comment_body(notifiable), with: "Number #{n + 1} is the best!"
      click_button submit_comment_text(notifiable)
      within "#comments" do
        expect(page).to have_content "Number #{n + 1} is the best!"
      end
      logout
    end

    login_as author
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_link text: "There are 3 new comments on"
  end

  scenario "A user replied to my comment" do
    comment = create(:comment, commentable: notifiable, user: author)

    reply_to(comment, with: "I replied to your comment", replier: create(:user, :verified))

    logout
    login_as author
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_link text: "Someone replied to your comment on"
  end

  scenario "Multiple replies to my comment" do
    comment = create(:comment, commentable: notifiable, user: author)
    users = 3.times.map { create(:user, :verified) }

    users.each.with_index do |user, n|
      login_as(user)
      visit path_for(notifiable)

      within("#comment_#{comment.id}_reply") { click_link "Reply" }
      within "#js-comment-form-comment_#{comment.id}" do
        fill_in comment_body(notifiable), with: "Reply number #{n}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Reply number #{n}"
      end
      logout
    end

    login_as author
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_link text: "There are 3 new replies to your comment on"
  end

  scenario "Author commented on his own notifiable" do
    login_as(author)
    visit path_for(notifiable)

    fill_in comment_body(notifiable), with: "I commented on my own notifiable"
    click_button submit_comment_text(notifiable)
    within "#comments" do
      expect(page).to have_content "I commented on my own notifiable"
    end

    within("#notifications") do
      click_link "You don't have new notifications"

      expect(page).to have_css ".notification", count: 0
    end
  end

  scenario "Author replied to his own comment" do
    comment = create(:comment, commentable: notifiable, user: author)

    reply_to(comment, with: "I replied to my own comment", replier: author)

    within("#notifications") do
      click_link "You don't have new notifications"

      expect(page).to have_css ".notification", count: 0
    end
  end
end
