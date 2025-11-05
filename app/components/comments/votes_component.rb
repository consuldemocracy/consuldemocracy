class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end
  
  private

  # We must use `vote_weight` to get an accurate count.

  def yes_votes_count
    # Counts only "Yes" (weight: 1)
    @comment.votes_for.where(vote_weight: 1).count
  end

  def no_votes_count
    # Counts only "No" (weight: -1)
    @comment.votes_for.where(vote_weight: -1).count
  end
  
  def not_sure_votes_count
    # Counts only "Not Sure" (weight: 0)
    @comment.votes_for.where(vote_weight: 0).count
  end

  # Helper to get the title of the parent object (the Debate)
  
  def votable_title_for_aria_label
    # A comment's "commentable" is the object it belongs to (the Debate)
    if @comment.commentable&.respond_to?(:title)
      @comment.commentable.title
    else
      # Fallback in case the parent doesn't have a title
      t("comments.comment.a_comment")
    end
  end
end
