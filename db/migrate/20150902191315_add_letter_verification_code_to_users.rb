class AddLetterVerificationCodeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :letter_verification_code, :string
  end
end
