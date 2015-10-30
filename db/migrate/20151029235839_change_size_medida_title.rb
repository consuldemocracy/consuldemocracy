class ChangeSizeMedidaTitle < ActiveRecord::Migration
  def change
    #ALTER TABLE medidas ALTER FIELD title
    execute "ALTER TABLE medidas ALTER COLUMN title TYPE VARCHAR(800)"
    change_column :medidas, :title, :string, limit: 800
  end
end
