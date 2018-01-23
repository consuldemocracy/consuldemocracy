class MergedCommentTree < CommentTree
  attr_accessor :commentables, :array_order

  def initialize(commentables, page, order = 'confidence_score', concealed = false)
    @commentables = commentables
    @commentable = commentables.first
    @page = page
    @order = order
    @array_order = set_array_order(order)

    @comments = root_comments(concealed) + root_descendants(concealed)
  end

  def root_comments(concealed = false)
    Kaminari.paginate_array(commentables.flatten.map(&:comments).map(&:roots).flatten.sort_by {|a| a[array_order]}.reverse).
    page(page).per(ROOT_COMMENTS_PER_PAGE)
  end

  def set_array_order(order)
    case order
    when "newest"
      "created_at"
    else
      "confidence_score"
    end
  end

end
