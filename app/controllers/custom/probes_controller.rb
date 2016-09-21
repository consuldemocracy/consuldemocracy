class ProbesController < ApplicationController
  skip_authorization_check

  def show
    @probe = Probe.find_by_codename params[:id]
    @probe_options = @probe.probe_options.all.order(cached_votes_up: :desc)
    load_user_vote

    render @probe.codename
  end

  private

    def load_user_vote
      @probe_option = @probe.option_voted_by(current_user) if current_user
    end
end