require "rails_helper"

describe "rake db:dev_seed" do
  before { Rake::Task["db:dev_seed"].reenable }

  it "seeds the database without errors" do
    expect { Rake.application.invoke_task("db:dev_seed") }.not_to raise_error
  end

  it "can seed a tenant" do
    create(:tenant, schema: "democracy")

    Rake.application.invoke_task("db:dev_seed[democracy]")

    expect(Debate.count).to eq 0
    Tenant.switch("democracy") { expect(Debate.count).not_to eq 0 }
  end
end
