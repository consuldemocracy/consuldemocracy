class AddPgTrgmExtension < ActiveRecord::Migration[4.2]
  def change
    execute "create extension if not exists pg_trgm"
  end
end
