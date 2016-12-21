class Legislation::QuestionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process

  def show
  end
end
