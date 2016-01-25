class MeetingsController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :js

  def index
    @filter = ResourceFilter.new(Meeting, params)
    @meetings = @filter.collection.upcoming

    respond_to do |format|
      format.html
      format.js { render json: @meetings.to_json }
    end
  end

  def show
    @meeting = Meeting.find(params[:id])
  end
end
