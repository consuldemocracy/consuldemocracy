require "rails_helper"

describe "AUE routes" do
  it "maps goals to their code" do
    expect(get("/aue/goals/1")).to route_to(
      controller: "aue/goals",
      action: "show",
      code: "1"
    )
  end

  it "requires using the code instead of the ID" do
    expect(get(aue_goal_path(AUE::Goal[2].code))).to route_to(
      controller: "aue/goals",
      action: "show",
      code: "2"
    )
  end
end
