class Topic < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  belongs_to :community
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :topics

  has_many :comments, as: :commentable, inverse_of: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_by_most_commented, -> { reorder(comments_count: :desc) }
end

# == Schema Information
#
# Table name: topics
#
#  id             :integer          not null, primary key
#  title          :string           not null
#  description    :text
#  author_id      :integer
#  comments_count :integer          default(0)
#  community_id   :integer
#  hidden_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
