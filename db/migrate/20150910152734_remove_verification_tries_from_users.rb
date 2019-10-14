class RemoveVerificationTriesFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :sms_confirmation_tries,       :integer,  default: 0
    remove_column :users, :residence_verification_tries, :integer,  default: 0
    remove_column :users, :letter_verification_tries,    :integer,  default: 0
  end
end
