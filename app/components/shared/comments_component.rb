class Shared::CommentsComponent < ApplicationComponent
  attr_reader :record, :comment_tree
  delegate :current_user, :current_order, :locale_and_user_status, :commentable_cache_key, to: :helpers

  def initialize(record, comment_tree)
    @record = record
    @comment_tree = comment_tree
  end

  private

    def cache_key
      [
        locale_and_user_status,
        current_order,
        commentable_cache_key(record),
        comment_tree.comments,
        comment_tree.comment_authors,
        record.comments_count
      ]
    end
end
