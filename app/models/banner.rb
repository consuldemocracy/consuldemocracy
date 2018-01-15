class Banner < ActiveRecord::Base

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  validates :title, presence: true,
                    length: { minimum: 2 }
  validates :description, presence: true
  validates :target_url, presence: true
  validates :post_started_at, presence: true
  validates :post_ended_at, presence: true

  has_many :sections
  has_many :web_sections, through: :sections

  scope :with_active,   -> { where("post_started_at <= ?", Time.current).where("post_ended_at >= ?", Time.current) }

  scope :with_inactive, -> { where("post_started_at > ? or post_ended_at < ?", Time.current, Time.current) }
end
