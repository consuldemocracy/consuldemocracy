class RemoveCommunityIdForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key "proposals", "communities"
    remove_foreign_key "budget_investments", "communities"
  end
end
