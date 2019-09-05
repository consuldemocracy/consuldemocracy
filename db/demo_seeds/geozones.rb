section "Creating DEMO Geozones" do
  %w[North West East Central].each_with_index do |name, i|
    code = i + 1
    Geozone.create!(name: "#{name} District",
                    external_code: "00#{code}",
                    census_code: "0#{code}")
  end
end
