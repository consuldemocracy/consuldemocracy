class Problem < ActiveRecord::Base

  validates :title, presence: true
  validates :summary, presence: true
  has_and_belongs_to_many :geozones

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :proposals

end
