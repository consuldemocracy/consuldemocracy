module Categorizable
  extend ActiveSupport::Concern

  included do
    belongs_to :category
    belongs_to :subcategory

    validates :category_id, presence: true
    validates :subcategory_id, presence: true

    validate :categorization
  end

  def categorization
    if subcategory && subcategory.category != category
      errors.add(:subcategory, "Subcategory is not within the record's Category.")
    end
  end
end
