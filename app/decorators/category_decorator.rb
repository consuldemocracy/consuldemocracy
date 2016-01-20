class CategoryDecorator < ApplicationDecorator
  delegate_all
  decorates_association :subcategories

  translates :name, :description

  def proposals_path
    h.proposals_path(filter: "category_id=#{id}")
  end

  def code
    "#{position}."
  end

  def name_with_code
    "#{code} #{name}"
  end
end
