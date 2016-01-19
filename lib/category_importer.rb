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
    category = Category.create(data)

    subcategories.each do |subcategory_data|
      Subcategory.create(subcategory_data.merge("category" => category))
    end

    category
  end
  private_class_method :import_category
end
