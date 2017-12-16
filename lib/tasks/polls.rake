namespace :polls do
  desc "Adds created_at and updated_at values to existing polls"
  task initialize_timestamps: :environment do
    Poll.update_all(created_at: Time.current, updated_at: Time.current)
  end
end
