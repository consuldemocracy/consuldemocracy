class Project < ApplicationRecord
  include Imageable
  include Cardable
  include Sluggable

  translates :title, touch: true
  translates :content, touch: true
  translates :teaser, touch: true
  include Globalizable

  enum :state, { draft: 0, active: 1, archived: 2 }

  has_many :phases, class_name: "Project::Phase"

  validates_translation :title, presence: true
  validates_translation :content, presence: true

  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]*\Z/, message: :slug_format }


  scope :active,      -> { where(state: 'active') }
  scope :archived,    -> { where(state: 'archived') }
  scope :published,   -> { where.not(state: 'draft') }
  scope :sort_by_created, -> { order(created_at: :desc) }

  def name
    title
  end

  def generate_slug?
    slug.nil?
  end

  def published?
    state != 'draft'
  end

  def url
    "/#{slug}"
  end

  def status
    state
  end


  def next_phase_order
    phase = self.phases.order(order: :desc).first;
    if phase
      return phase.order + 1;
    end
    return 1;
  end
end

