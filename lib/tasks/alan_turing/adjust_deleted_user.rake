require "csv"

namespace :db do
  desc "Import data from the CSV files"
  task adjust_deleted_user: :environment do
    print "Adjusting Deleted users: "
    User.find(2).update_columns(username: "usuario_2",
                                email: "usuario_2@consul.dev")
    user_deleted = User.create!(username: "Usuario eliminado",
                                email: "usuario_eliminado@consul.dev",
                                password: "12345678",
                                password_confirmation: "12345678",
                                confirmed_at: Time.current,
                                terms_of_service: "1",
                                erased_at: Time.current)
    Proposal.where(author_id: 2).each { |proposal| proposal.update_columns(author_id: user_deleted.id) }
    proposal = Proposal.find(1)
    proposal.update_columns(author_id: 2)
    proposal.touch
    puts "done!"
  end
end
