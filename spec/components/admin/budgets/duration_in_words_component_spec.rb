require "rails_helper"

describe Admin::Budgets::DurationInWordsComponent do
  it "describes the total duration in human language" do
    durable = double(
      starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0),
      ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00)
    )

    render_inline Admin::Budgets::DurationInWordsComponent.new(durable)

    expect(page.text).to eq "about 1 year"
  end

  it "is not defined when no end date is defined" do
    durable = double(starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0), ends_at: nil)

    render_inline Admin::Budgets::DurationInWordsComponent.new(durable)

    expect(page).not_to be_rendered
  end

  it "is not defined when no start date is defined" do
    durable = double(starts_at: nil, ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00))

    render_inline Admin::Budgets::DurationInWordsComponent.new(durable)

    expect(page).not_to be_rendered
  end
end
