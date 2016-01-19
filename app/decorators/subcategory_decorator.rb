class SubcategoryDecorator < ApplicationDecorator
  delegate_all
  decorates_association :category

  translates :name, :description

  def proposals_path
    h.proposals_path(filter: "category_id=#{category.id}:subcategory_id=#{id}")
  end
end
