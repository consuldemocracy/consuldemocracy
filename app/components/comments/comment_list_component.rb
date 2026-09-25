class Comments::CommentListComponent < ApplicationComponent
  attr_reader :comments, :valuation

  def initialize(comments, valuation: false)
    @comments = comments
    @valuation = valuation
  end
end
