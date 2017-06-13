class LegacyLegislationsController < ApplicationController
  load_and_authorize_resource

  def show
    @legacy_legislation = LegacyLegislation.find(params[:id])
  end

end
