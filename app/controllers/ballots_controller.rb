class BallotsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_ballot
  load_and_authorize_resource

  def show
  end

  private

    def load_ballot
      @ballot = current_user.ballot
    end

end
