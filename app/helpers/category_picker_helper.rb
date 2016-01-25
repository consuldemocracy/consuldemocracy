module CategoryPickerHelper
  def category_picker(record, options = {})
    react_component(
      'CategoryPicker',
      categoryInputName: options.fetch(:axis_name, "#{record.class.name.downcase}[category_id]"),
      subcategoryInputName: options.fetch(:action__line_name, "#{record.class.name.downcase}[subcategory_id]"),
      categories: serialized_categories,
      subcategories: serialized_subcategories,
      selectedCategoryId: record.category_id.to_s,
      selectedSubcategoryId: record.subcategory_id.to_s
    )
  end
end
