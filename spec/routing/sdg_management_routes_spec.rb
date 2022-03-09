require "rails_helper"

describe "SDG Management routes" do
  it "maps routes for relatable classes" do
    expect(get("/sdg_management/proposals")).to route_to(
      controller: "sdg_management/relations",
      action: "index",
      relatable_type: "proposals"
    )
  end

  it "admits named routes" do
    expect(get(sdg_management_polls_path)).to route_to(
      controller: "sdg_management/relations",
      action: "index",
      relatable_type: "polls"
    )
  end

  it "routes relatable types containing a slash" do
    expect(url_for(
      controller: "sdg_management/relations",
      action: "index",
      relatable_type: "legislation/processes",
      only_path: true
    )).to eq "/sdg_management/legislation/processes"
  end

  it "does not accept non-relatable classes" do
    expect(get("/sdg_management/tags")).not_to be_routable
  end
end
