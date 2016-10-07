module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable
  end

  def commentable_path
    self
  end

  def commentable_title
    self.title
  end

end
