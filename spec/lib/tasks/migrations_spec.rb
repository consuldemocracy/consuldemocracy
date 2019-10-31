require "rails_helper"

describe "Migration tasks" do
  let(:run_rake_task) do
    Rake::Task["migrations:valuation_taggings"].reenable
    Rake.application.invoke_task("migrations:valuation_taggings")
  end

  it "updates taggings" do
    valuation_tagging = create(:tagging, context: "valuation")
    another_valuation_tagging = create(:tagging, context: "valuation")
    valuation_tags_tagging = create(:tagging, context: "valuation_tags")
    tags_tagging = create(:tagging)

    run_rake_task

    expect(valuation_tagging.reload.context).to eq "valuation_tags"
    expect(another_valuation_tagging.reload.context).to eq "valuation_tags"
    expect(valuation_tags_tagging.reload.context).to eq "valuation_tags"
    expect(tags_tagging.reload.context).to eq "tags"
  end
end
