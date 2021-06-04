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
    expect(page).to have_content "Someone commented on"
    expect(page).to have_xpath "//a[@href='#{notification_path(notification)}']"
  end

  scenario "Multiple users commented on my notifiable" do
    3.times do |n|
      login_as(create(:user, :verified))

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
    expect(page).to have_content "There are 3 new comments on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "A user replied to my comment" do
    comment = create :comment, commentable: notifiable, user: author

    login_as(create(:user, :verified))
    visit path_for(notifiable)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in comment_body(notifiable), with: "I replied to your comment"
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "I replied to your comment"
    end

    logout
    login_as author
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "Someone replied to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Multiple replies to my comment" do
    comment = create :comment, commentable: notifiable, user: author

    3.times do |n|
      login_as(create(:user, :verified))
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
    expect(page).to have_content "There are 3 new replies to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
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
    comment = create :comment, commentable: notifiable, user: author

    login_as author
    visit path_for(notifiable)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in comment_body(notifiable), with: "I replied to my own comment"
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "I replied to my own comment"
    end

    within("#notifications") do
      click_link "You don't have new notifications"

      expect(page).to have_css ".notification", count: 0
    end
  end
end
