class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_voter

  validates :first_name,        presence: true, if: :use_first_name?
  validates :last_name,         presence: true, if: :use_last_name?
  validates :nickname,          presence: true, if: :use_nickname?
  validates :organization_name, presence: true, if: :is_organization

  has_one :administrator
  has_one :moderator
  has_one :organization

  scope :administrators, -> { joins(:administrators) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }

  attr_accessor :organization_name
  attr_accessor :is_organization

  after_save :create_associated_organization

  def name
    return nickname          if use_nickname?
    return organization.name if organization?
    "#{first_name} #{last_name}"
  end

  def votes_on_debates(debates_ids = [])
    debates_ids = debates_ids.flatten.compact.uniq
    return {} if debates_ids.empty?

    voted = votes.where("votable_type = ? AND votable_id IN (?)", "Debate", debates_ids)
    voted.each_with_object({}){ |v,_| _[v.votable_id] = v.vote_flag }
  end

  def administrator?
    administrator.present?
  end

  def moderator?
    moderator.present?
  end

  def organization?
    organization.present?
  end

  private
    def use_first_name?
      !is_organization && !use_nickname?
    end

    def use_last_name?
      use_first_name?
    end

    def create_associated_organization
      create_organization(name: organization_name) if is_organization
    end

end
