class RemoveSearchKeywordFromVisits < ActiveRecord::Migration[7.0]
  def change
    remove_column :visits, :search_keyword, :string
  end
end
