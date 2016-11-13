class GraphqlController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def query
    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
