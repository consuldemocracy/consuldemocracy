class Admin::Api::StatsController < Admin::Api::BaseController
  def show
    unless params[:event].present? ||
           params[:visits].present? ||
           params[:budget_investments].present? ||
           params[:user_supported_budgets].present?
      return render json: {}, status: :bad_request
    end

    ds = Ahoy::DataSource.new

    if params[:event].present?
      ds.add params[:event].titleize, Ahoy::Event.where(name: params[:event]).group_by_day(:time).count
    end

    if params[:visits].present?
      ds.add "Visits", Visit.group_by_day(:started_at).count
    end

    if params[:budget_investments].present?
      ds.add "Budget Investments", Budget::Investment.group_by_day(:created_at).count
    end

    if params[:user_supported_budgets].present?
      ds.add "User supported budgets", Vote.where(votable_type: "Budget::Investment").group_by_day(:updated_at).count
    end
    render json: ds.build
  end
end
