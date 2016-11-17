class GraphqlController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def query
    # ConsulSchema.execute returns the query result in the shape of a Hash, which
    # is sent back to the client rendered in JSON
    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
