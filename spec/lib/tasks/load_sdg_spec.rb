require "rails_helper"

describe "rake db:load_sdg" do
  before { Rake::Task["db:load_sdg"].reenable }

  let :run_rake_task do
    Rake.application.invoke_task("db:load_sdg")
  end

  it "populates empty databases correctly" do
    SDG::Goal.destroy_all

    run_rake_task

    expect(SDG::Goal.count).to eq 17
  end

  it "does not create additional records on populated databases" do
    expect(SDG::Goal.count).to eq 17

    goal_id = SDG::Goal.last.id

    run_rake_task

    expect(SDG::Goal.count).to eq 17
    expect(SDG::Goal.last.id).to eq goal_id
  end
end
