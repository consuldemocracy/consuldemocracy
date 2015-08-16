class User < ActiveRecord::Base
  apply_simple_captcha
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_voter

  validates :first_name, presence: true, unless: :use_nickname?
  validates :last_name, presence: true, unless: :use_nickname?
  validates :nickname, presence: true, if: :use_nickname?
  validates :official_level, inclusion: {in: 0..5}

  def name
    use_nickname? ? nickname : "#{first_name} #{last_name}"
  end

  def debate_votes(debates)
    voted = votes.for_debates.in(debates)
    voted.each_with_object({}) { |v, _| _[v.votable_id] = v.value }
  end

  def administrator?
    @is_administrator ||= Administrator.where(user_id: id).exists?
  end

  def moderator?
    @is_moderator ||= Moderator.where(user_id: id).exists?
  end

  def official?
    official_level && official_level > 0
  end

  def add_official_position!(position, level)
    update official_position: position, official_level: level.to_i
  end

  def remove_official_position!
    update official_position: nil, official_level: 0
  end
end
