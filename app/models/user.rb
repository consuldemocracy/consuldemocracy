class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_voter

  validates :first_name, presence: true, unless: :use_nickname?
  validates :last_name, presence: true, unless: :use_nickname?
  validates :nickname, presence: true, if: :use_nickname?

  def name
    use_nickname? ? nickname : "#{first_name} #{last_name}"
  end

  def votes_on_debates(debates_ids = [])
    debates_ids = debates_ids.flatten.compact.uniq
    return {} if debates_ids.empty?

    voted = votes.where("votable_type = ? AND votable_id IN (?)", "Debate", debates_ids)
    voted.each_with_object({}){ |v,_| _[v.votable_id] = v.vote_flag }
  end
end
