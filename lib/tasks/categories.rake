namespace :categories do
  FILENAME = Rails.root.join('db', 'seeds', 'categories.json')

  desc "Export categories and subcategories from database to json"
  task export: :environment do
    categories = Category.all.map do |category|
      {
        id: category.id,
        name: category.name,
        description: category.description,
        subcategories: Subcategory.where(category_id: category.id).all.map do |subcategory|
          {
            id: subcategory.id,
            name: subcategory.name,
            description: subcategory.description
          }
        end
      }
    end

    File.open(FILENAME, 'w') do |f| 
      f.write(JSON.pretty_generate({categories: categories}))
    end
  end

  desc "Import categories and subcategories from a json file"
  task import: :environment do
    CategoryImporter.import(FILENAME)
  end
end

