class AddTokensToVisits < ActiveRecord::Migration[7.0]
  def change
    change_table :visits do |t|
      t.string :visit_token
      t.string :visitor_token
    end

    add_index :visits, :visit_token, unique: true
    add_index :visits, [:visitor_token, :started_at]
  end
end
