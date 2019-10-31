namespace :migrations do
  desc "Migrates context of valuation taggings"
  task valuation_taggings: :environment do
    ApplicationLogger.new.info "Updating valuation taggings context"
    Tagging.where(context: "valuation").update_all(context: "valuation_tags")
  end
end
