class AddIsPublishedToJob < ActiveRecord::Migration[7.1]
  def change
    remove_column :sensemaker_jobs, :path, :text
    add_column :sensemaker_jobs, :published, :boolean, default: false
  end
end
