require_dependency Rails.root.join('app', 'controllers', 'debates_controller').to_s

class DebatesController < ApplicationController

  def destroy
    if @debate.destroyable?
      @debate.destroy
      redirect_to debates_path, notice: t('flash.actions.destroy.debate')
    else
      redirect_to debates_path, flash: { error: t('flash.actions.destroy_forbidden.debate') }
    end
  end

end
