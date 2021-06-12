require "rails_helper"

describe "rake db:load_sdg" do
  before { Rake::Task["db:load_sdg"].reenable }

  let :run_rake_task do
    Rake.application.invoke_task("db:load_sdg")
  end

  it "populates empty databases and assigns targets correctly" do
    SDG::Goal.destroy_all
    SDG::Phase.destroy_all

    run_rake_task

    expect(SDG::Goal.count).to eq 17
    expect(SDG::Target.count).to eq 169
    expect(SDG::Target["17.1"].goal.code).to eq 17
    expect(SDG::Phase.count).to eq 3
  end

  it "does not create additional records on populated databases" do
    expect(SDG::Goal.count).to eq 17
    expect(SDG::Target.count).to eq 169
    expect(SDG::Phase.count).to eq 3

    goal_id = SDG::Goal.last.id
    target_id = SDG::Target.last.id
    phase_id = SDG::Phase.last.id

    run_rake_task

    expect(SDG::Goal.count).to eq 17
    expect(SDG::Target.count).to eq 169
    expect(SDG::Phase.count).to eq 3
    expect(SDG::Goal.last.id).to eq goal_id
    expect(SDG::Target.last.id).to eq target_id
    expect(SDG::Phase.last.id).to eq phase_id
  end
end

describe "rake db:calculate_tsv" do
  before { Rake::Task["db:calculate_tsv"].reenable }

  let :run_rake_task do
    Rake.application.invoke_task("db:calculate_tsv")
  end

  it "calculates the tsvector for polls" do
    poll = create(:poll)
    poll.update_column(:tsv, nil)

    expect(poll.reload.tsv).to be nil

    run_rake_task

    expect(poll.reload.tsv).not_to be nil
  end

  it "calculates the tsvector for legislation processes" do
    process = create(:legislation_process)
    process.update_column(:tsv, nil)

    expect(process.reload.tsv).to be nil

    run_rake_task

    expect(process.reload.tsv).not_to be nil
  end
end
