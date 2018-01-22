class Budget
  class Group < ActiveRecord::Base
    include Sluggable

    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates :budget_id, presence: true
    validates :name, presence: true, uniqueness: { scope: :budget }
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/

    def to_param
      name.parameterize
    end

    def single_heading_group?
      headings.count == 1
    end
  end
end
