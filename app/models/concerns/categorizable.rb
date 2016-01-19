module Categorizable
  extend ActiveSupport::Concern

  included do
    belongs_to :category
    belongs_to :subcategory

    validate :categorization
  end

  def categorization
    if subcategory && subcategory.category != category
      errors.add(:subcategory, "Subcategory is not within the record's Category.")
    end
  end
end
