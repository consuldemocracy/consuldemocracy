class AddResidenceVerificationTriesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :residence_verification_tries, :integer, default: 0
  end
end
