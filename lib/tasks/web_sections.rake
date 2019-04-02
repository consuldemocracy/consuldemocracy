namespace :web_sections do
  desc "Generate web sections for banners"
  task generate: :environment do
    WebSection.where(name: "homepage").first_or_create
    WebSection.where(name: "debates").first_or_create
    WebSection.where(name: "proposals").first_or_create
    WebSection.where(name: "budgets").first_or_create
    WebSection.where(name: "help_page").first_or_create
  end
end
