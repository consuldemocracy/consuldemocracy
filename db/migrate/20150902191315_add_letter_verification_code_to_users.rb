class AddLetterVerificationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :letter_verification_code, :string
  end
end
