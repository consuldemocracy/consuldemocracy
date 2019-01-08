namespace :slugs do
  desc "Generate slug attribute for objects from classes that use Sluggable concern"
  task generate: :environment do
    %w(Budget Budget::Heading Budget::Group).each do |class_name|
      class_name.constantize.find_each(&:generate_slug)
    end
  end
end
