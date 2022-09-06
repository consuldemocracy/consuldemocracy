require "rails_helper"

describe Admin::DurationComponent do
  it "shows both dates when both are defined" do
    durable = double(
      starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0),
      ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00)
    )

    render_inline Admin::DurationComponent.new(durable)

    expect(page.text).to eq "2015-08-01 12:00 - 2016-09-30 16:29"
    expect(page).to have_css "time", exact_text: "2015-08-01 12:00"
    expect(page).to have_css "time", exact_text: "2016-09-30 16:29"
  end

  it "shows the start date when no end date is defined" do
    durable = double(starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0), ends_at: nil)

    render_inline Admin::DurationComponent.new(durable)

    expect(page.text).to eq "2015-08-01 12:00 - "
  end

  it "shows the end date when no start date is defined" do
    durable = double(starts_at: nil, ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00))

    render_inline Admin::DurationComponent.new(durable)

    expect(page.text).to eq "- 2016-09-30 16:29"
  end
end
