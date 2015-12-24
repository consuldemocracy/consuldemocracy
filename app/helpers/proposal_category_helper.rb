module ProposalCategoryHelper
  def proposal_category_picker(record, options = {})
    react_component(
      'ProposalCategoryPicker',
      categoryInputName: options.fetch(:axis_name, 'proposal[category_id]'),
      subcategoryInputName: options.fetch(:action__line_name, 'proposal[subcategory_id]'),
      categories: serialized_categories,
      subcategories: serialized_subcategories,
      selectedCategoryId: record.category.try(:id),
      selectedSubcategoryId: record.subcategory.try(:id),
    )
  end

  def serialized_categories
    Category.all.map do |category|
      {
        id: category.id,
        name: localize_attribute(category.name)
      }
    end
  end

  def serialized_subcategories
    Subcategory.all.map do |subcategory|
      {
        id: subcategory.id,
        name: localize_attribute(subcategory.name),
        description: localize_attribute(subcategory.description),
        categoryId: subcategory.category_id
      }
    end
  end

  def localize_attribute(attribute)
    attribute[I18n.locale.to_s] if attribute
  end
end
