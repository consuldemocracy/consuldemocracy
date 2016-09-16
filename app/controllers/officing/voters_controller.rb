class Officing::VotersController < Officing::BaseController
  layout 'admin'

  before_action :authenticate_user!

  def new
  end

end