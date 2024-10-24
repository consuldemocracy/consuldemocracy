class AddResidenceVerificationTriesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :residence_verification_tries, :integer, default: 0
  end
end
