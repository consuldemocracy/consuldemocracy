class Admin::Poll::ShiftsController < Admin::BaseController
  
  before_action :load_booth
  before_action :load_polls

  def new
    load_officers
    load_shifts
    @shift = ::Poll::Shift.new
  end

  def create
    @shift = ::Poll::Shift.new(shift_params)
    if @shift.save
      notice = t("admin.poll_shifts.flash.create")
      redirect_to new_admin_booth_shift_path(@shift.booth), notice: notice
    else
      load_officers
      load_shifts
      render :new
    end
  end

  def destroy
    @shift = Poll::Shift.find(params[:id])
    @shift.destroy
    notice = t("admin.poll_shifts.flash.destroy")
    redirect_to new_admin_booth_shift_path(@booth), notice: notice
  end

  private

    def load_booth
      @booth = ::Poll::Booth.find(params[:booth_id])
    end

    def load_polls
      @polls = ::Poll.current_or_incoming
    end

    def load_officers
      @officers = ::Poll::Officer.all
    end

    def load_shifts
      @shifts = @booth.shifts
    end

    def shift_params
      params.require(:shift).permit(:booth_id, :officer_id, :date)
    end

end