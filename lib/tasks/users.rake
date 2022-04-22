namespace :users do
  desc "Remove users data with empty email"
  task remove_users_data: :environment do
    User.where(email: nil).each do |user|
      user.update_columns(document_number: nil, document_type: nil)
      print "."
    end
  end
end
