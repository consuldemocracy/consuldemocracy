require "rails_helper"

describe Admin::Budgets::DurationComponent do
  describe "#dates" do
    it "shows both dates when both are defined" do
      durable = double(
        starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0),
        ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00)
      )

      dates = Admin::Budgets::DurationComponent.new(durable).dates

      render dates

      expect(page.text).to eq "2015-08-01 12:00 - 2016-09-30 16:29"
      expect(dates).to be_html_safe
    end

    it "shows the start date when no end date is defined" do
      durable = double(starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0), ends_at: nil)
      render Admin::Budgets::DurationComponent.new(durable).dates

      expect(page.text).to eq "2015-08-01 12:00 - "
    end

    it "shows the end date when no start date is defined" do
      durable = double(starts_at: nil, ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00))

      render Admin::Budgets::DurationComponent.new(durable).dates

      expect(page.text).to eq "- 2016-09-30 16:29"
    end
  end

  describe "#duration" do
    it "describes the total duration in human language" do
      durable = double(
        starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0),
        ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00)
      )

      render Admin::Budgets::DurationComponent.new(durable).duration

      expect(page.text).to eq "about 1 year"
    end

    it "is not defined when no end date is defined" do
      durable = double(starts_at: Time.zone.local(2015, 8, 1, 12, 0, 0), ends_at: nil)

      render Admin::Budgets::DurationComponent.new(durable).duration

      expect(page).not_to be_rendered
    end

    it "is not defined when no start date is defined" do
      durable = double(starts_at: nil, ends_at: Time.zone.local(2016, 9, 30, 16, 30, 00))

      render Admin::Budgets::DurationComponent.new(durable).duration

      expect(page).not_to be_rendered
    end
  end

  attr_reader :content

  def render(content)
    @content = content
  end

  def page
    Capybara::Node::Simple.new(content.to_s)
  end
end
