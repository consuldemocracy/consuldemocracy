class EnquiriesController < ApplicationController
  load_and_authorize_resource

  def index
    @enquiries = @enquiries.sort_for_list.for_render
  end

  def show
  end

end
