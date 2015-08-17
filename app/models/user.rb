class User < ActiveRecord::Base
  apply_simple_captcha
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_voter

  has_one :administrator
  has_one :moderator
  has_one :organization

  validates :first_name, presence: true, if: :use_first_name?
  validates :last_name,  presence: true, if: :use_last_name?
  validates :nickname,   presence: true, if: :use_nickname?

  validates_associated :organization, message: false

  accepts_nested_attributes_for :organization

  scope :administrators, -> { joins(:administrators) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }

  attr_accessor :organization_name
  attr_accessor :is_organization

  def name
    return nickname          if use_nickname?
    return organization.name if organization?
    "#{first_name} #{last_name}"
  end

  def debate_votes(debates)
    voted = votes.for_debates.in(debates)
    voted.each_with_object({}) { |v, _| _[v.votable_id] = v.value }
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
      !organization? && !use_nickname?
    end

    def use_last_name?
      use_first_name?
    end
end
