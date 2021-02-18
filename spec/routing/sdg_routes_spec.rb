require "rails_helper"

describe "SDG routes" do
  it "maps goals to their code" do
    expect(get("/sdg/goals/1")).to route_to(
      controller: "sdg/goals",
      action: "show",
      code: "1"
    )
  end

  it "requires using the code instead of the ID" do
    expect(get(sdg_goal_path(SDG::Goal[2].code))).to route_to(
      controller: "sdg/goals",
      action: "show",
      code: "2"
    )
  end
end
