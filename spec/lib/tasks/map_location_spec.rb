require "rails_helper"

describe "rake map_locations:destroy" do
  before do
    create(:map_location, :proposal_map_location)
    empty_location = create(:map_location, :proposal_map_location)
    empty_location.attributes = { longitude: nil, latitude: nil, zoom: nil }
    empty_location.save(validate: false)
  end

  let :run_rake_task do
    Rake.application.invoke_task("map_locations:destroy")
  end

  it "destroys empty locations" do
    expect(MapLocation.all.size).to eq(2)
    run_rake_task
    expect(MapLocation.all.size).to eq(1)
  end
end
