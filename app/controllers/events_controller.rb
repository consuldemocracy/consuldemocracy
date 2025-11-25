# frozen_string_literal: true

class EventsController < ApplicationController
  skip_authorization_check

  def index
    # 1. Calculate @start_date
    # We explicitly convert to string first to ensure .blank? and parsing works
    @start_date = resolve_start_date(params[:start_date].to_s)

    # 2. Use it for the query
    @calendar_items = Event.all_in_range(
      @start_date.beginning_of_month,
      @start_date.end_of_month
    )
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def resolve_start_date(date_param)
    # 1. Handle empty params (Defaults to Today)
    return Date.current if date_param.blank?

    begin
      # 2. Try Standard ISO first (YYYY-MM-DD)
      # This handles the "Next/Previous" buttons from simple_calendar
      Date.iso8601(date_param)
    rescue ArgumentError
      begin
        # 3. Fallback to Application Locale (e.g. DD/MM/YYYY)
        # This handles your custom datepicker inputs
        Date.strptime(date_param, I18n.t("date.formats.default"))
      rescue ArgumentError, TypeError
        # 4. If the data is garbage, fallback to Today to prevent crash
        Date.current
      end
    end
  end
end
