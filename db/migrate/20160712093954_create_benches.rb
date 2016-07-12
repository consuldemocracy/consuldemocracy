class CreateBenches < ActiveRecord::Migration
  def change
    create_table :benches do |t|
      t.string :name
      t.string :code
    end
  end
end
