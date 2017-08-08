module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follows, as: :followable, dependent: :destroy
    has_many :followers, through: :follows, source: :user
  end

  def followed_by?(user)
    followers.include?(user)
  end

end
