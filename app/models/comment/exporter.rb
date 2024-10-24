class Comment::Exporter
  include JsonExporter

  def model
    Comment
  end

  private

    def json_values(comment)
      {
        id: comment.id,
        commentable_id: comment.commentable_id,
        commentable_type: comment.commentable_type,
        body: strip_tags(comment.body)
      }
    end
end
