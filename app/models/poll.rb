class Poll < ActiveRecord::Base
  has_many :booths
  has_many :voters, through: :booths, class_name: "Poll::Voter"
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
end
