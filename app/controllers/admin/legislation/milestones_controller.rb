class Admin::Legislation::MilestonesController < Tracking::MilestonesController
  include FeatureFlags
  feature_flag :legislation

  def index
    @process = milestoneable
  end

  private

    def milestoneable
      ::Legislation::Process.find(params[:process_id])
    end
end
