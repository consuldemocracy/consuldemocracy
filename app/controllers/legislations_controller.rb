class LegislationsController < ApplicationController
  load_and_authorize_resource

  def show
    @legislation = Legislation.find(params[:id])
  end

end