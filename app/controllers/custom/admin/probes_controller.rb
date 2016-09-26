class Admin::ProbesController < Admin::BaseController

  def index
    @probes = Probe.all.order(created_at: :desc).page(params[:page])
  end

  def show
    @probe = Probe.find(params[:id])
  end

end