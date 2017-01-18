class Budget
  class Group < ActiveRecord::Base
    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates :budget_id, presence: true
    validates :name, presence: true

    before_save :set_slug

    def set_slug
      self.slug = name.parameterize
    end

    def to_param
      name.parameterize
    end

  end
end