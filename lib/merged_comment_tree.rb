class MergedCommentTree < CommentTree
  attr_reader :commentables

  def initialize(commentables, page, order = "confidence_score")
    @commentables = commentables
    super(commentables.first, page, order)
  end

  def base_comments
    Comment.where(commentable: commentables.flatten)
  end
end
