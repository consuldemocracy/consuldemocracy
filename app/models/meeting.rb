class Meeting < ActiveRecord::Base
  include PgSearch
  include SearchCache
  include Categorizable

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :meeting_proposals
  accepts_nested_attributes_for :meeting_proposals
  has_many :proposals, through: :meeting_proposals

  scope :pending, -> { where(closed_at: nil) } 
  scope :closed, -> { where('closed_at is not ?', nil) } 
  scope :upcoming, -> { where("held_at >= ?", Date.today) }

  validates :author, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :held_at, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

  pg_search_scope :pg_search, {
    against: {
      title:       'A',
      description: 'B'
    },
    using: {
      tsearch: { dictionary: "spanish", tsvector_column: 'tsv' }
    },
    ignoring: :accents,
    ranked_by: '(:tsearch)'
  }

  def searchable_values
    values = {
      title       => 'A',
      description => 'B'
    }
    values[author.username] = 'C'
    values
  end

  def self.search(terms)
    self.pg_search(terms)
  end
end
