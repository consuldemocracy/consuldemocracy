class Article < ActiveRecord::Base
  VALID_STATUSES = %w(draft published)

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]*\Z/, message: :slug_format }
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :published, -> { where(status: 'published').order('id DESC') }
end
