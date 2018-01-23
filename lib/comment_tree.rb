class CommentTree

  ROOT_COMMENTS_PER_PAGE = 10

  attr_accessor :root_comments, :comments, :commentable, :page, :order

  def initialize(commentable, page, order = 'confidence_score', concealed = false)
    @commentable = commentable
    @page = page
    @order = order

    @comments = root_comments(concealed) + root_descendants(concealed)
  end

  def root_comments(concealed = false)
    commentable.comments.where(concealed: concealed).
                roots.send("sort_by_#{order}").page(page).
                per(ROOT_COMMENTS_PER_PAGE).for_render
  end

  def root_descendants(concealed = false)
    root_comments(concealed).each_with_object([]) do |root, array|
      array.concat(Comment.where(concealed: concealed).
                          descendants_of(root).send("sort_descendants_by_#{order}").
                          for_render.to_a)
    end
  end

  def ordered_children_of(parent)
    comments_by_parent_id[parent.id] || []
  end

  def comments_by_parent_id
    comments.each_with_object({}) do |comment, array|
      (array[comment.parent_id] ||= []) << comment
    end
  end

  def comment_authors
    comments.map(&:author)
  end
end
