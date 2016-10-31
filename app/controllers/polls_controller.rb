class PollsController < ApplicationController

  load_and_authorize_resource

  def index

  end

  def show
    @questions = @poll.questions.sort_for_list.for_render
  end

end
