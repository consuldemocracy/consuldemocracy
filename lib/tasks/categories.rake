namespace :categories do
  desc "Export categories and subcategories from database to json"
  task export: :environment do
    filename = "#{Rails.root}/db/seeds/categories.json"

    categories = Category.all.map do |category|
      {
        name: category.name,
        description: category.description,
        subcategories: Subcategory.where(category_id: category.id).all.map do |subcategory|
          {
            name: subcategory.name,
            description: subcategory.description
          }
        end
      }
    end

    File.open(filename, 'w') do |f| 
      f.write(JSON.pretty_generate({categories: categories}))
    end
  end
end
