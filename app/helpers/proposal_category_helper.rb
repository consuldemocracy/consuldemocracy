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
end
