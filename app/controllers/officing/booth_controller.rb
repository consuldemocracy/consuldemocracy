class Officing::BoothController < Officing::BaseController
  before_action :load_officer_assignment
  before_action :verify_officer_assignment

  def new
    @booths = current_user.poll_officer.todays_booths
  end

  def create
    set_booth(Poll::Booth.find(booth_params[:id]))
    redirect_to officing_root_path
  end

  private

    def booth_params
      params.require(:booth).permit(:id)
    end

    def set_booth(booth)
      session[:booth_id] = booth.id
    end
end
