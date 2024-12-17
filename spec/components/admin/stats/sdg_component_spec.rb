require "rails_helper"

describe Admin::Stats::SDGComponent do
  include Rails.application.routes.url_helpers

  it "renders a links to go back to the admin stats index" do
    render_inline Admin::Stats::SDGComponent.new(SDG::Goal.all)

    expect(page).to have_link "Go back", href: admin_stats_path
  end
end
