module Comments
  def comment_on(commentable, user = nil)
    user ||= create(:user)

    comment = create(:comment, commentable: commentable, user: user)
    CommentNotifier.new(comment: comment).process
  end

  def reply_to(original_user, manuela = nil)
    manuela ||= create(:user)

    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: original_user)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: "It will be done next week."
      click_button "Publish reply"
    end
    expect(page).to have_content "It will be done next week."
  end

  def avatar(name)
    "img.initialjs-avatar[data-name='#{name}']"
  end
end
