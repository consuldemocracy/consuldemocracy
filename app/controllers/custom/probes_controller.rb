class ProbesController < ApplicationController
  skip_authorization_check

  before_action :load_probe
  before_action :load_probe_options, only: [:show]
  before_action :load_user_selection, only: [:show, :thanks]

  def show
    render probe_show_page
  end

  def selection
    if params[:option_id].blank?
      redirect_to probe_show_route
    else
      @probe_option = @probe.probe_options.find(params[:option_id])
      @probe_option.select(current_user)
      redirect_to probe_thanks_route
    end
  end

  def thanks
    if @probe_option.blank?
      redirect_to probe_show_route
    else
      render "probes/#{@probe.codename}/thanks"
    end
  end

  private

    def probe_show_page
      @probe.selecting_allowed? ? "probes/#{@probe.codename}/selecting" : "probes/#{@probe.codename}/results"
    end

    def load_user_selection
      @probe_option = @probe.option_voted_by(current_user) if current_user
    end

    def load_probe
      @probe = Probe.find_by! codename: params[:id]
    end

    def load_probe_options
      order = @probe.selecting_allowed? ? "RANDOM()" : { probe_selections_count: :desc }
      @probe_options = @probe.probe_options.all.includes(:debate).order(order)
    end

    def probe_show_route
      method("#{@probe.codename}_path").call
    end

    def probe_thanks_route
      method("#{@probe.codename}_thanks_path").call
    end
end