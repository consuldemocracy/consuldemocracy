class AddLetterVerificationTriesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :letter_verification_tries, :integer, default: 0
  end
end
