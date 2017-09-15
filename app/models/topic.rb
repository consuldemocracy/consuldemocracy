class Topic < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :community
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_by_most_commented, -> { reorder(comments_count: :desc) }

end
