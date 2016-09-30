class GraphqlController < ApplicationController
  authorize_resource :proposal

  def query
    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
