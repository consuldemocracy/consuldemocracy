class AddUnaccentExtension < ActiveRecord::Migration
  def change
    execute "create extension unaccent if not exists unaccent"
  end
end
