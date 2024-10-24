class AddSmsVerificationCodeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sms_verification_code, :string
    add_column :users, :sms_verified_at, :datetime
  end
end
