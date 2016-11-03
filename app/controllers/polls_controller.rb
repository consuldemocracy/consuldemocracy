class PollsController < ApplicationController

  load_and_authorize_resource

  has_filters %w{current expired incoming}

  def index
    @polls = @polls.send(@current_filter).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.sort_for_list.for_render
  end

end
