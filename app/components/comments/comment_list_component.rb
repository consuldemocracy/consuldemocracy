class Comments::CommentListComponent < ApplicationComponent
  attr_reader :comments, :comment_tree, :valuation

  def initialize(comments, comment_tree:, valuation: false)
    @comments = comments
    @comment_tree = comment_tree
    @valuation = valuation
  end
end
