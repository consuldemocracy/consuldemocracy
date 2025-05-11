class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def show
    render json: { status: "ok" }, status: :ok
  end
end 