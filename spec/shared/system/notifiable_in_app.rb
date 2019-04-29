shared_examples "notifiable in-app" do |described_class|

  let(:author) { create(:user, :verified) }
  let!(:notifiable) { create(model_name(described_class), author: author) }

  scenario "Notification icon is shown" do
    notification = create(:notification, notifiable: notifiable, user: author)

    login_as author
    visit root_path

    expect(page).to have_css ".icon-notification"
  end

  scenario "A user commented on my notifiable", :js do
    notification = create(:notification, notifiable: notifiable, user: author)

    login_as author
    visit root_path
    find(".icon-notification").click

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "Someone commented on"
    expect(page).to have_xpath "//a[@href='#{notification_path(notification)}']"
  end

  scenario "Multiple users commented on my notifiable", :js do
    3.times do
      login_as(create(:user, :verified))

      visit path_for(notifiable)

      fill_in comment_body(notifiable), with: "I agree"
      click_button "publish_comment"
      within "#comments" do
        expect(page).to have_content "I agree"
      end
      logout
    end

    login_as author
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "There are 3 new comments on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "A user replied to my comment", :js do
    comment = create :comment, commentable: notifiable, user: author

    login_as(create(:user, :verified))
    visit path_for(notifiable)

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
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "Someone replied to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Multiple replies to my comment", :js do
    comment = create :comment, commentable: notifiable, user: author

    3.times do |n|
      login_as(create(:user, :verified))
      visit path_for(notifiable)

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
    visit notifications_path

    expect(page).to have_css ".notification", count: 1
    expect(page).to have_content "There are 3 new replies to your comment on"
    expect(page).to have_xpath "//a[@href='#{notification_path(Notification.last)}']"
  end

  scenario "Author commented on his own notifiable", :js do
    login_as(author)
    visit path_for(notifiable)

    fill_in comment_body(notifiable), with: "I commented on my own notifiable"
    click_button "publish_comment"
    within "#comments" do
      expect(page).to have_content "I commented on my own notifiable"
    end

    within("#notifications") do
      find(".icon-no-notification").click
      expect(page).to have_css ".notification", count: 0
    end
  end

  scenario "Author replied to his own comment", :js do
    comment = create :comment, commentable: notifiable, user: author

    login_as author
    visit path_for(notifiable)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: "I replied to my own comment"
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "I replied to my own comment"
    end

    within("#notifications") do
      find(".icon-no-notification").click
      expect(page).to have_css ".notification", count: 0
    end

  end

end
