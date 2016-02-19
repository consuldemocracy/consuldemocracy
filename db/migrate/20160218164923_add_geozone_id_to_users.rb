class AddGeozoneIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :geozone, index: true, foreign_key: true
  end
end
