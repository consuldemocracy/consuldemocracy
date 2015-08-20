class Moderation::DebatesController < Moderation::BaseController

  def hide
    @debate = Debate.find(params[:id])
    @debate.hide
  end

end