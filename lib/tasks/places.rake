namespace :places do
  desc "Generate a yml file with random Barcelona places for seeds"
  task :generate_seeds do
    filename = "#{Rails.root}/db/seeds/places.yml"
    boundings = [
      [41.405199, 2.136749],
      [41.389167, 2.184815]
    ]

    random = Random.new 
    places = []

    100.times do
      lat = random.rand(boundings[1][0]..boundings[0][0])
      lng = random.rand(boundings[0][1]..boundings[1][1])
      address = Geocoder.search("#{lat},#{lng}").first.formatted_address
      places.push({
        lat: lat,
        lng: lng,
        address: address
      })
    end

    File.open(filename, 'w') do |f| 
      f.write({places: places}.to_yaml)
    end
  end
end
