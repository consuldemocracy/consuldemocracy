require "rails_helper"

describe Admin::Poll::Questions::FilterComponent do
  it "renders a button to submit the form" do
    render_inline Admin::Poll::Questions::FilterComponent.new([])

    expect(page).to have_button "Filter"
  end
end
