class AddPgTrgmExtension < ActiveRecord::Migration
  def change
    execute "create extension if not exists pg_trgm"
  end
end
