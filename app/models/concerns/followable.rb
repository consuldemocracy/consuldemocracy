module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follows, as: :followable, dependent: :destroy
    has_many :followers, through: :follows, source: :user

    scope :followed_by_user, ->(user){
      joins(:follows).where("follows.user_id = ?", user.id)
    }
  end

  def followed_by?(user)
    followers.include?(user)
  end

end
