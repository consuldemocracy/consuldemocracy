namespace :web_sections do
  desc "Generate web sections for banners"
  task generate: :environment do
    WebSection.create(name: 'homepage')
    WebSection.create(name: 'debates')
    WebSection.create(name: 'proposals')
    WebSection.create(name: 'budgets')
    WebSection.create(name: 'more_info')
  end
end
