class GraphqlController < ApplicationController

  skip_authorization_check

  def query
    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
