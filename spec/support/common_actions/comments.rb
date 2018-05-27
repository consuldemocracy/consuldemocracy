module Comments
  # spec/features/emails_spec.rb
  # spec/models/vote_spec.rb
  def comment_on(commentable, user = nil)
    user ||= create(:user)

    comment = create(:comment, commentable: commentable, user: user)
    CommentNotifier.new(comment: comment).process
  end

  # spec/features/emails_spec.rb
  def reply_to(original_user, manuela = nil)
    manuela ||= create(:user)

    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: original_user)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: 'It will be done next week.'
      click_button 'Publish reply'
    end
    expect(page).to have_content 'It will be done next week.'
  end
  
  # spec/features/account_spec.rb
  # spec/features/comments/budget_investments_spec.rb
  # spec/features/comments/budget_investments_valuation_spec.rb
  # spec/features/comments/debates_spec.rb
  # spec/features/comments/legislation_annotations_spec.rb
  # spec/features/comments/legislation_questions_spec.rb
  # spec/features/comments/polls_spec.rb
  # spec/features/comments/proposals_spec.rb
  # spec/features/comments/topics_spec.rb
  # spec/features/debates_spec.rb
  # spec/features/proposals_spec.rb
  def avatar(name)
    "img.initialjs-avatar[data-name='#{name}']"
  end
end
