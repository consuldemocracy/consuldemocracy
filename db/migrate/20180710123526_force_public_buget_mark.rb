class ForcePublicBugetMark < ActiveRecord::Migration
  def change
    add_column :budgets, :force_public, :boolean
  end
end
