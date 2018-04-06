class Admin::ProbesController < Admin::BaseController

  def index
    @probes = Probe.all.order(created_at: :desc).page(params[:page])
  end

  def show
    @probe = Probe.find(params[:id])
    @probe_options = @probe.probe_options.order(probe_selections_count: :desc)
  end

end