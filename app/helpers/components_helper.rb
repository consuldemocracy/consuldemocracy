module ComponentsHelper
  def serialized_categories
    Category.all.map do |category|
      {
        id: category.id.to_s,
        name: localize_attribute(category.name)
      }
    end
  end

  def serialized_subcategories
    Subcategory.all.map do |subcategory|
      {
        id: subcategory.id.to_s,
        name: localize_attribute(subcategory.name),
        description: localize_attribute(subcategory.description),
        categoryId: subcategory.category_id.to_s
      }
    end
  end

  def localize_attribute(attribute)
    attribute[I18n.locale.to_s] if attribute
  end

  def google_maps_autocomplete_input(options = {})
    react_component(
      'GoogleMapsAutocompleteInput',
      defaultLocation: options[:default_location],
      addressInputId: options[:address_input_id],
      latitudeInputId: options[:latitude_input_id],
      longitudeInputId: options[:longitude_input_id]
    ) 
  end
end
