class ChangeSizeMedidaTitle < ActiveRecord::Migration
  def change
    #ALTER TABLE medidas ALTER FIELD title
    change_column :medidas, :title, :string, limit: 800
  end
end
