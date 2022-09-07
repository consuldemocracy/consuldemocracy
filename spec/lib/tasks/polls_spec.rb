require "rails_helper"

describe "rake polls:set_ends_at_to_end_of_day" do
  before { Rake::Task["polls:set_ends_at_to_end_of_day"].reenable }

  let :run_rake_task do
    Rake.application.invoke_task("polls:set_ends_at_to_end_of_day")
  end

  it "updates existing polls" do
    travel_to(Time.zone.local(2015, 7, 15, 13, 32, 13))
    poll = create(:poll, ends_at: 2.years.from_now)
    date_poll = create(:poll, ends_at: 3.years.from_now.to_date)

    expect(I18n.l(poll.reload.ends_at, format: :datetime)).to eq "2017-07-15 13:32:13"
    expect(I18n.l(date_poll.reload.ends_at, format: :datetime)).to eq "2018-07-15 00:00:00"

    run_rake_task

    expect(I18n.l(poll.reload.ends_at, format: :datetime)).to eq "2017-07-15 23:59:00"
    expect(I18n.l(date_poll.reload.ends_at, format: :datetime)).to eq "2018-07-15 23:59:00"
  end
end
