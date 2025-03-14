module Comments
  def reply_to(comment, replier: create(:user))
    login_as(replier)

    visit polymorphic_path(comment.commentable)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end
    expect(page).to have_content "It will be done next week."
  end
end
