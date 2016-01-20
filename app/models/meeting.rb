class Meeting < ActiveRecord::Base
  include PgSearch
  include SearchCache

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_and_belongs_to_many :proposals

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
