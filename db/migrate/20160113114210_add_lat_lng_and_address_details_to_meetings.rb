class AddLatLngAndAddressDetailsToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :address_latitude, :float
    add_column :meetings, :address_longitude, :float
    add_column :meetings, :address_details, :string
  end
end
