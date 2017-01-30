class Legislation::Annotation < ActiveRecord::Base
  COMMENTS_PAGE_SIZE = 5
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  serialize :ranges, Array

  belongs_to :draft_version, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_draft_version_id'
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable, dependent: :destroy

  validates :text, presence: true
  validates :quote, presence: true
  validates :draft_version, presence: true
  validates :author, presence: true

  after_create :create_first_comment

  def create_first_comment
    comments.create(body: self.text, user: self.author)
  end

  def title
    text[0..50]
  end
end
