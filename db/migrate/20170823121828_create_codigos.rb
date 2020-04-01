class CreateCodigos < ActiveRecord::Migration[4.2]
  def change
    create_table :codigos do |t|
      t.string :clave
      t.string :valor
    end
    add_index :codigos, :clave
  end
end
