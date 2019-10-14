class AddPointsToBallot < ActiveRecord::Migration
  def change

    add_column :budget_ballot_lines, :points, :integer,null: nil
  end
end
