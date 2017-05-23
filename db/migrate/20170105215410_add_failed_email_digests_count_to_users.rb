class AddFailedEmailDigestsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_email_digests_count, :integer, default: 0
  end
end
