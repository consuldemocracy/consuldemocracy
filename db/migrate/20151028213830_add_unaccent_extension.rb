class AddUnaccentExtension < ActiveRecord::Migration
  def change
    execute "create extension unaccent"
  end
end
