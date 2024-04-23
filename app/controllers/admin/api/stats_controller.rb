class Admin::Api::StatsController < Admin::Api::BaseController
  def show
    if params[:event].present?
      render json: Ahoy::Chart.new(params[:event]).data_points
    else
      render json: {}, status: :bad_request
    end
  end
end
