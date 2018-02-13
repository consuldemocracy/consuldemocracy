class Budget
  class Group < ActiveRecord::Base
    include Sluggable

    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates :budget_id, presence: true
    validates :name, presence: true, uniqueness: { scope: :budget }
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/

    scope :by_slug, ->(slug) { where(slug: slug) }

    before_save :strip_name

    def to_param
      slug
    end

    def single_heading_group?
      headings.count == 1
    end

    def generate_slug?
      slug.nil? || budget.drafting?
    end

    private

    def strip_name
      self.name = self.name.strip
    end

  end
end
