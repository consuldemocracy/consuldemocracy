class MeetingsController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :json

  def index
    @filter = ResourceFilter.new(Meeting.upcoming, params)
    @meetings = @filter.collection

    respond_to do |format|
      format.html
      format.json do 
        render json: {
          meetings: @meetings,
          filter: @filter
        }
      end
    end
  end

  def show
    @meeting = Meeting.find(params[:id])
  end
end
