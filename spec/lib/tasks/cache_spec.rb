require "rails_helper"

describe "rake cache:clear" do
  before { Rake::Task["cache:clear"].reenable }

  it "clears the cache", :with_cache do
    Rails.cache.write("tests/cache_exists", true)

    expect(Rails.cache.fetch("tests/cache_exists") { false }).to be true

    Rake.application.invoke_task("cache:clear")

    expect(Rails.cache.fetch("tests/cache_exists") { false }).to be false
  end
end
