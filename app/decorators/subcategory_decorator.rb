class SubcategoryDecorator < ApplicationDecorator
  delegate_all
  decorates_association :category

  translate :name

  def proposals_path
    h.proposals_path(filter: "category_id=#{category.id}:subcategory_id=#{id}")
  end
end
