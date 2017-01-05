class Legislation::Annotation < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  serialize :ranges, Array

  belongs_to :draft_version, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_draft_version_id'
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable

  validates :text, presence: true
  validates :quote, presence: true
  validates :draft_version, presence: true
  validates :author, presence: true

  def title
    text[0..50]
  end
end
