class Legislation::ProcessesController < Legislation::BaseController
  has_filters %w{open next past}, only: :index
  load_and_authorize_resource

  def index
    @current_filter ||= 'open'
    @processes = ::Legislation::Process.send(@current_filter).page(params[:page])
  end

  def show
  end
end
