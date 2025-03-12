module Comments
  def reply_to(comment, with: "I like what you say", replier: create(:user))
    login_as(replier)

    visit polymorphic_path(comment.commentable)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "Leave your comment", with: with
      click_button "Publish reply"
    end
    expect(page).to have_content with
  end
end
