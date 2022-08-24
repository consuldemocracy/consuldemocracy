class ChangeUserTokensToJsonb < ActiveRecord::Migration[5.2]
  def change
    change_column(:users, :tokens, :jsonb)
  end
end
