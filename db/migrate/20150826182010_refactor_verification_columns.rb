class RefactorVerificationColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :sms_verification_code, :sms_confirmation_code

    remove_column :users, :sms_verified_at, :datetime
    remove_column :users, :email_verified_at, :datetime
    remove_column :users, :email_for_verification, :string
    remove_column :users, :verified_user_sms_verified_at, :datetime
    add_column :users, :verified_at, :datetime

    remove_column :users, :phone, :string
    add_column :users, :unconfirmed_phone, :string
    add_column :users, :confirmed_phone, :string

    remove_column :users, :letter_requested, :boolean, default: false
    add_column :users, :letter_requested_at, :datetime

    rename_column :users, :sms_tries, :sms_confirmation_tries
  end
end
