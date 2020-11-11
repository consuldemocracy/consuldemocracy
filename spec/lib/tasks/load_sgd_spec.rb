require "rails_helper"

describe "rake db:load_sdg" do
  let :run_rake_task do
    Rake.application.invoke_task("db:load_sdg")
  end

  it "seeds the database without errors" do
    expect { run_rake_task }.not_to raise_error
  end
end
