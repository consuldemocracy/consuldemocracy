class Polls::PollComponent < ApplicationComponent
  attr_reader :poll
  use_helpers :cannot?, :user_signed_in?, :current_user, :link_to_poll

  def initialize(poll)
    @poll = poll
  end

  private

    def dates
      if poll.starts_at.blank? || poll.ends_at.blank?
        I18n.t("polls.no_dates")
      else
        I18n.t("polls.dates", open_at: l(poll.starts_at.to_date), closed_at: l(poll.ends_at.to_date))
      end
    end
end
