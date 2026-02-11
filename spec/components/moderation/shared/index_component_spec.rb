require "rails_helper"

describe Moderation::Shared::IndexComponent do
  let(:records) { Debate.none.page(1) }

  before do
    allow(vc_test_controller).to receive_messages(
      valid_filters: %w[pending_flag_review all with_ignored_flag],
      current_filter: "all"
    )
  end

  around do |example|
    with_request_url("/moderation/debates") { example.run }
  end

  it "highlights active filter without link, shows others as links" do
    render_inline Moderation::Shared::IndexComponent.new(records)

    expect(page).not_to have_link "All"
    expect(page).to have_css "li.is-active", text: "All"
    expect(page).to have_link "Pending"
    expect(page).to have_link "Marked as viewed"
  end
end
