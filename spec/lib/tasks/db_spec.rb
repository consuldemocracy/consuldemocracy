require "rails_helper"

describe "rake db:pages" do
  let :run_rake_task do
    Rake.application.invoke_task("db:pages")
  end

  it "seeds the database with the default custom pages" do
    SiteCustomization::Page.destroy_all
    expect(SiteCustomization::Page.count).to be 0

    run_rake_task
    expect(SiteCustomization::Page.count).to be 7
  end
end
