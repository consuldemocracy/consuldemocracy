class BallotsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_ballot
  load_and_authorize_resource

  def show
  end

  private

    def load_ballot
      @ballot = Ballot.where(user: current_user).first_or_create
    end

end
