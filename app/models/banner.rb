class Banner < ActiveRecord::Base

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  validates :title, presence: true,
                    length: { minimum: 2 }
  validates :description, presence: true
  validates :target_url, presence: true
  validates :style, presence: true
  validates :image, presence: true
  validates :post_started_at, presence: true
  validates :post_ended_at, presence: true

  scope :with_active,   -> { where("post_started_at <= ?", Time.current).where("post_ended_at >= ?", Time.current) }

  scope :with_inactive, -> { where("post_started_at > ? or post_ended_at < ?", Time.current, Time.current) }

end

# == Schema Information
#
# Table name: banners
#
#  id              :integer          not null, primary key
#  title           :string(80)
#  description     :string
#  target_url      :string
#  style           :string
#  image           :string
#  post_started_at :date
#  post_ended_at   :date
#  hidden_at       :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
