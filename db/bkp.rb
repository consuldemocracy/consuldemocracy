require 'json'

file = File.read('ny_coordinates.json')
data_hash = JSON.parse(file)

coordinates = []
geography_id = nil 

data_hash["features"].each do |feature|
  coordinates = feature["geometry"]["coordinates"][0]
  geography_id = feature["properties"]["CounDist"]
  #puts "\n"
  #puts feature["geometry"]["coordinates"].length
  #puts "\n\n"
  #puts feature["geometry"]["coordinates"][0]
  #puts "\n"
  #break
  puts "Creating geography: "
  puts geography_id
  puts "\n\n"

  fixed_coordinates = []
  coordinates.each do |coor|
    fixed_coor = [] 
    fixed_coor << coor[1]
    fixed_coor << coor[0]
    fixed_coordinates << fixed_coor
  end

  
  Geography.create(name: "District " + geography_id.to_s, outline_points: fixed_coordinates)
end
