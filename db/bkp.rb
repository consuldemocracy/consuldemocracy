require 'json'

file = File.read('ny_coordinates.json')
data_hash = JSON.parse(file)

coordinates = []
geography_id = nil 

Budget::Heading.all.each do |h|
  h.geography_id = nil
  h.save
end

Geography.all.each do |g|
  g.destroy
end

data_hash["features"].each do |feature|
  #coordinates = feature["geometry"]["coordinates"]
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

  #fixed_coordinates = []
  #coordinates.each do |coor|
  #  fixed_coor = [] 
  #  fixed_coor << coor[1]
  #  fixed_coor << coor[0]
  #  fixed_coordinates << fixed_coor
  #end

  puts "\n\n\n\n"
  puts feature.to_json
  puts "\n\n\n\n"

  Geography.create(name: "District " + geography_id.to_s, outline_points: feature.to_json, color: ['#0081aa', '#0097aa', '#0063aa', '#00baaa'].sample)

end

headings = Budget::Heading.all
geography_ids = []
Geography.all.each do |g|
  geography_ids << g.id
end

headings.each do |heading|
  id = geography_ids.sample
  heading.geography_id = id
  geography_ids.delete(id)
  heading.save
end
