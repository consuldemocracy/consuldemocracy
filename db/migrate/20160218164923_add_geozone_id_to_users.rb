class AddGeozoneIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :geozone, index: true, foreign_key: true
  end
end
