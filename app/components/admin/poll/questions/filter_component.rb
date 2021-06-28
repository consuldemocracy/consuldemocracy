class Admin::Poll::Questions::FilterComponent < ApplicationComponent
  attr_reader :polls
  delegate :current_path_with_query_params, to: :helpers

  def initialize(polls)
    @polls = polls
  end

  private

    def poll_select_options
      options = polls.map do |poll|
        [poll.name, current_path_with_query_params(poll_id: poll.id)]
      end
      options_for_select(options, request.fullpath)
    end
end
