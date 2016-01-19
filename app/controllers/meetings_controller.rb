class MeetingsController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @meetings = Meeting.upcoming
  end

  def show
    @meeting = Meeting.find(params[:id])
  end
end
