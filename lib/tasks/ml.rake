namespace :ml do
  desc "Resets all Machine Learning data and jobs to allow for fresh testing"
  task reset: :environment do
    puts "Starting Machine Learning environment reset..."

    ActiveRecord::Base.transaction do
      # 1. Delete dependent children first to avoid Foreign Key Violations
      puts "Cleaning up child records..."
      RelatedContentScore.delete_all

      # 2. Delete main ML records
      puts "Cleaning up ML models..."
      RelatedContent.delete_all
      MlSummaryComment.delete_all
      MachineLearningInfo.delete_all
      MachineLearningJob.delete_all

      # 3. Handle Tagging cleanup
      puts "Cleaning up ML tags..."
      Tagging.where(context: "ml_tags").delete_all
      # Optional: Clean up orphaned tags that have no other taggings
      Tag.where("NOT EXISTS (SELECT 1 FROM taggings WHERE taggings.tag_id = tags.id)").delete_all

      # 4. Clear physical files
      puts "Cleaning up intermediate data files..."
      FileUtils.rm_rf(Dir.glob(MachineLearning.data_folder.join("*.{json,csv}")))
    end

    puts "✅ Machine Learning environment has been reset."
    puts "Freshness checks will now treat all records as new."
  end
end
