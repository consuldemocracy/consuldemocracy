class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  has_many :notifications

  def username
    user.username
  end

  def made_by?(user)
    self.user == user
  end
end
