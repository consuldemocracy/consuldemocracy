namespace :proposals do

  desc "Move external_url to description"
  task move_external_url_to_description: :environment do
    include ActionView::Helpers::SanitizeHelper
    include TextWithLinksHelper

    models = [Proposal, Legislation::Proposal]

    models.each do |model|
      print "Move external_url to description for #{model}s"
      model.find_each do |resource|
        if resource.external_url.present?
          Globalize.with_locale(I18n.default_locale) do
            new_description = "#{resource.description} <p>#{text_with_links(resource.external_url)}</p>"
            resource.description = new_description
            resource.external_url = ""
            resource.updated_at = Time.current
            resource.save(validate: false)
            print "."
          end
        end
      end
      puts " ✅ "
    end
  end
end
