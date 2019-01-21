class Budget
  class Group < ActiveRecord::Base
    include Sluggable

    translates :name, touch: true
    include Globalizable

    belongs_to :budget

    has_many :headings, dependent: :destroy

    before_validation :assign_model_to_translations

    validates_translation :name, presence: true
    validates :budget_id, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :max_votable_headings, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :max_supportable_headings, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

    scope :by_slug, ->(slug) { where(slug: slug) }
    scope :sort_by_name, -> { includes(:translations).order(:name) }

    before_save :strip_name

    def to_param
      slug
    end

    def single_heading_group?
      headings.count == 1
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

    def strip_name
      name.strip!
    end
  end
end
