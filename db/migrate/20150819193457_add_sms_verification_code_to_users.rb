class AddSmsVerificationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_verification_code, :string
    add_column :users, :sms_verified_at, :datetime
  end
end
