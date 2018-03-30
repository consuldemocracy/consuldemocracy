class Article < ActiveRecord::Base
  include Imageable

  VALID_STATUSES = %w(draft published)

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :author, presence: true
  validates :content, presence: true

  scope :published, -> { where(status: 'published').order('id DESC') }

  def to_param
    "#{id}-#{title}".parameterize
  end

end
