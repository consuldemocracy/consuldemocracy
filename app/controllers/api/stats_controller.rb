class Api::StatsController < Api::ApiController
  def show
    event_type = params[:event]
    unless event_type.present?
      return render json: {}, status: :bad_request
    end

    render json: Ahoy::Event.where(name: event_type).group_by_day(:time).count
  end
end
