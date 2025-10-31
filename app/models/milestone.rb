class Milestone < ApplicationRecord
  include Imageable
  include Documentable

  translates :title, :description, touch: true
  include Globalizable

  translation_class_delegate :status_id

  belongs_to :milestoneable, polymorphic: true
  belongs_to :status

  validates :milestoneable, presence: true
  validates :publication_date, presence: true
  validates_translation :description, presence: true, unless: -> { status_id.present? }

  scope :order_by_publication_date, -> { order(publication_date: :asc, created_at: :asc) }
  scope :published,                 -> { where(publication_date: ..Date.current.end_of_day) }
  scope :with_status,               -> { where.not(status_id: nil) }
  scope :public_for_api, -> do
    where(milestoneable: [Proposal.public_for_api, Budget::Investment.public_for_api])
  end

  def self.title_max_length
    80
  end
end
