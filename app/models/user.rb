class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_voter

  validates :first_name, presence: true, if: :use_first_name?
  validates :last_name,  presence: true, if: :use_last_name?
  validates :nickname,   presence: true, if: :use_nickname?

  def name
    return nickname          if use_nickname?
    return organization_name if organization?
    "#{first_name} #{last_name}"
  end

  def votes_on_debates(debates_ids = [])
    debates_ids = debates_ids.flatten.compact.uniq
    return {} if debates_ids.empty?

    voted = votes.where("votable_type = ? AND votable_id IN (?)", "Debate", debates_ids)
    voted.each_with_object({}){ |v,_| _[v.votable_id] = v.vote_flag }
  end

  def administrator?
    @is_administrator ||= Administrator.where(user_id: id).exists?
  end

  def moderator?
    @is_moderator ||= Moderator.where(user_id: id).exists?
  end

  def organization?
    organization_name.present?
  end

  def verified_organization?
    organization_verified_at.present?
  end

  private
    def use_first_name?
      !use_nickname? && !organization?
    end

    def use_last_name?
      use_first_name?
    end

end
