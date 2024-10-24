class Admin::Legislation::ProgressBarsController < Admin::ProgressBarsController
  include FeatureFlags
  feature_flag :legislation

  def index
    @process = progressable
  end

  private

    def progressable
      ::Legislation::Process.find(params[:process_id])
    end
end
