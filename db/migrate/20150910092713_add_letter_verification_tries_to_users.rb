class AddLetterVerificationTriesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :letter_verification_tries, :integer, default: 0
  end
end
