class GraphqlController < ApplicationController
  authorize_resource :proposal

  def query
    #puts "I'm the GraphqlController inside the #query action!!"

    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
