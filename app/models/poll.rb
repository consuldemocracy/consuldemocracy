class Poll < ActiveRecord::Base
  has_many :booth_assigments
  has_many :booths, through: :booth_assigments, class_name: "Poll::BoothAssignment"
  has_many :voters, through: :booths, class_name: "Poll::Voter"
  has_many :officers, through: :booths, class_name: "Poll::Officer"
  has_many :questions

  validates :name, presence: true

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Time.now, Time.now) }
  scope :incoming, -> { where('? < starts_at', Time.now) }
  scope :expired,  -> { where('ends_at < ?', Time.now) }

  scope :sort_for_list, -> { order(:starts_at) }

  def current?(timestamp = DateTime.now)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def incoming?(timestamp = DateTime.now)
    timestamp < starts_at
  end

  def expired?(timestamp = DateTime.now)
    ends_at < timestamp
  end

  def answerable_by?(user)
    user.present? && user.level_two_or_three_verified? && current?
  end

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?
    current
  end
end
