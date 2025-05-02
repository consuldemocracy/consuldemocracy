module Comments
  def reply_to(comment, with: "I like what you say", replier: create(:user))
    login_as(replier)

    visit polymorphic_path(comment.commentable)

    within "#comment_#{comment.id}" do
      click_link "Reply"
    end

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in comment_body(comment.commentable), with: with
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content with
    end
  end
end
