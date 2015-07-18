class DebatesController < ApplicationController
  before_action :set_debate, only: [:show, :edit, :update]
  before_action :authenticate_user!, only: [:new, :create]
  
  def index
    @debates = Debate.all
  end

  def show
  end

  def new
    @debate = Debate.new
  end

  def edit
  end

  def create
    @debate = Debate.new(debate_params)
    @debate.author = current_user
    @debate.save
    respond_with @debate
  end

  def update
    @debate.update(debate_params)
    respond_with @debate
  end


  private
    def set_debate
      @debate = Debate.find(params[:id])
    end

    def debate_params
      params.require(:debate).permit(:title, :description, :external_link, :terms_of_service)
    end

end
