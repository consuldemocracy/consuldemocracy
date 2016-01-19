module ComponentsHelper
  def serialized_categories
    CategoryDecorator.decorate_collection(Category.all).map do |category|
      {
        id: category.id.to_s,
        name: category.name,
        description: category.description
      }
    end
  end

  def serialized_subcategories
    SubcategoryDecorator.decorate_collection(Subcategory.all).map do |subcategory|
      {
        id: subcategory.id.to_s,
        name: subcategory.name,
        description: subcategory.description,
        categoryId: subcategory.category_id.to_s
      }
    end
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
