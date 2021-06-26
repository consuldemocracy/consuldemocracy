class Shared::CommentsComponent < ApplicationComponent
  attr_reader :record, :comment_tree
  delegate :current_user, :current_order, :locale_and_user_status, :commentable_cache_key, to: :helpers

  def initialize(record, comment_tree)
    @record = record
    @comment_tree = comment_tree
  end
end
