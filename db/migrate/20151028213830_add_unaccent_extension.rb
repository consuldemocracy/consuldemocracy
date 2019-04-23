class AddUnaccentExtension < ActiveRecord::Migration[4.2]
  def change
    execute "create extension if not exists unaccent"
  end
end
