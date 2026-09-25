class Shared::CommentsComponent < ApplicationComponent
  attr_reader :record, :valuation
  delegate :current_order, :locale_and_user_status, :commentable_cache_key, to: :helpers

  def initialize(record, comment_tree = nil, valuation: false)
    @record = record
    @comment_tree = comment_tree
    @valuation = valuation
  end

  def comment_tree
    @comment_tree ||= CommentTree.new(record, params[:page], current_order, valuations: valuation)
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
