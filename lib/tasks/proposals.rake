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
          resource.update_columns(description: "#{resource.description} "\
                                  "<p>#{text_with_links(resource.external_url)}</p>",
                                  external_url: "", updated_at: Time.current)
          print "."
        end
      end
      puts " ✅ "
    end
  end
end
