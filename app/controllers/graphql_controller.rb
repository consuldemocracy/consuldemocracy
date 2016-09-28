class GraphqlController < ApplicationController

  def query
    #puts "I'm the GraphqlController inside the #query action!!"

    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
