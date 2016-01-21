module CategoryImporter
  # Public: Imports an Axis/ActionLine/Goal structure from a fixture file.
  #
  # file - The JSON file to import from.
  #
  # Returns an Array<Axis>
  def self.import(file)
    Category.transaction do
      JSON.parse(File.read(file))["categories"].map do |data|
        import_category(data)
      end
    end
  end

  def self.import_category(data)
    subcategories = data.delete("subcategories")

    if data["id"].present?
      id = data.delete "id"
      category = Category.find(id)
      category.update_attributes(data)
    else
      category = Category.create(data)
    end

    subcategories.each do |subcategory_data|
      if subcategory_data["id"].present?
        id = subcategory_data.delete "id"
        subcategory = Subcategory.find(id)
        subcategory.update_attributes(subcategory_data)
      else
        Subcategory.create(subcategory_data.merge("category" => category))
      end
    end

    category
  end
  private_class_method :import_category
end
