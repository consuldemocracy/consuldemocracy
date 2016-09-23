class EnquiriesController < ApplicationController
  load_and_authorize_resource

  has_filters %w{opened expired incoming}

  def index
    @enquiries = @enquiries.send(@current_filter).sort_for_list.for_render.page(params[:page])
  end

  def show
  end

end
