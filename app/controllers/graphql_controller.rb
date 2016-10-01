class GraphqlController < ApplicationController

  # (!!) Está autorizando todos los resources, no sólo Proposal ¿por qué?
  # (!!) Nos da acceso a recursos a los que se supone que no tenemos acceso, cómo 'Geozones', ¿por qué?
  authorize_resource :proposal

  def query
    render json: ConsulSchema.execute(
      params[:query],
      variables: params[:variables] || {}
    )
  end
end
