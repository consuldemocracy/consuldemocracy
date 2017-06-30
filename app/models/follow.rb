class Follow < ActiveRecord::Base
  belongs_to :user
  #TODO Rock&RoR: Check touch usage on cache system
  belongs_to :followable, polymorphic: true

  validates :user_id, presence: true
  validates :followable_id, presence: true
  validates :followable_type, presence: true

  scope(:by_user_and_followable, lambda do |user, followable|
    where(user_id: user.id,
          followable_type: followable.class.to_s,
          followable_id: followable.id)
  end)

  def self.followed?(user, followable)
    return false unless user
    !! by_user_and_followable(user, followable).try(:first)
  end

  def self.interests_by(user)
    interests = []
    user.follows.each do |follow|
      follow.followable.tags.each do |tag|
        interests << tag.name
      end
    end
    return interests.uniq
  end

end
