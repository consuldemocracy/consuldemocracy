require "csv"

namespace :db do
  desc "Import data from the CSV files"
  task related_users: :environment do
    puts "Creating Users Relations"
    csv_file = "lib/tasks/alan_turing/machine_learning_users_related_nmf.csv"
    CSV.foreach(csv_file, col_sep: ";", headers: false) do |line|
      list = line.to_a
      user_id = list.first
      if user_id.present?
        unless User.find_by_id(user_id)
          User.create!(id: user_id,
                       username: "usuario_#{user_id}",
                       email: "usuario_#{user_id}@consul.dev",
                       password: "12345678",
                       password_confirmation: "12345678",
                       confirmed_at: Time.current,
                       terms_of_service: "1")
        end
        list.delete(user_id)
        list.each do |related_user_id|
          if related_user_id.present?
            unless User.find_by_id(related_user_id)
              User.create!(id: related_user_id,
                           username: "usuario_#{related_user_id}",
                           email: "usuario_#{related_user_id}@consul.dev",
                           password: "12345678",
                           password_confirmation: "12345678",
                           confirmed_at: Time.current,
                           terms_of_service: "1")
            end
            unless RelatedUser.exists?(user_id, related_user_id)
              related_user = RelatedUser.create!(user_id: user_id, related_user_id: related_user_id)
              print "." if (related_user.id % 100) == 0
            end
          end
        end
      end
    end
    puts "\nUsers Relations created!"
  end
end
