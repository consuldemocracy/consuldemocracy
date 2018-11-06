namespace :map_locations do
  desc 'Destroy all empty MapLocation instances found in the database'
  task destroy: :environment do
    MapLocation.where(longitude: nil, latitude: nil, zoom: nil).each do |map_location|
      map_location.destroy
    end
  end
end
