namespace :users do

  desc "Enable recommendations for existing users"
  task enable_recommendations: :environment do
    User.find_each do |user|
      user.update(recommended_debates: true, recommended_proposals: true)
    end
  end

end
