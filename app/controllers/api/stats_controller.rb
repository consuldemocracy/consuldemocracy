class Api::StatsController < Api::ApiController

  def show
    unless params[:events].present? || params[:visits].present?
      return render json: {}, status: :bad_request
    end

    ds = Ahoy::DataSource.new

    if params[:events].present?
      event_types = params[:events].split ','
      event_types.each do |event|
        ds.add event.titleize, Ahoy::Event.where(name: event).group_by_day(:time).count
      end
    end

    if params[:visits].present?
      ds.add "Visits", Visit.group_by_day(:started_at).count
    end

    render json: ds.build
  end

end
