class CommentTree

  ROOT_COMMENTS_PER_PAGE = 10

  attr_accessor :root_comments, :comments

  def initialize(commentable, page, order = 'confidence_score')
    @root_comments = commentable.comments.roots.send("sort_by_#{order}").page(page).per(ROOT_COMMENTS_PER_PAGE).for_render

    root_descendants = @root_comments.each_with_object([]) do |root, col|
      col.concat(Comment.descendants_of(root).send("sort_by_#{order}").for_render.to_a)
    end

    @comments = root_comments + root_descendants

    @comments_by_parent_id = @comments.each_with_object({}) do |comment, col|
      (col[comment.parent_id] ||= []) << comment
    end
  end

  def children_of(parent)
    @comments_by_parent_id[parent.id] || []
  end

  def comment_authors
    comments.map(&:author)
  end
end
