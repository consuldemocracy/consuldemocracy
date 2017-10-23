class Admin::Poll::ShiftsController < Admin::Poll::BaseController

  before_action :load_booth
  before_action :load_officer

  def new
    load_shifts
    @shift = ::Poll::Shift.new
    @voting_polls = @booth.polls.current_or_incoming
    @recount_polls = @booth.polls.current_or_recounting_or_incoming
  end

  def create
    @shift = ::Poll::Shift.new(shift_params)
    @officer = @shift.officer

    if @shift.save
      redirect_to new_admin_booth_shift_path(@shift.booth), notice: t("admin.poll_shifts.flash.create")
    else
      load_shifts
      flash[:error] = t("admin.poll_shifts.flash.date_missing")
      render :new
    end
  end

  def destroy
    @shift = Poll::Shift.find(params[:id])
    @shift.destroy
    notice = t("admin.poll_shifts.flash.destroy")
    redirect_to new_admin_booth_shift_path(@booth), notice: notice
  end

  def search_officers
    @officers = User.search(params[:search]).order(username: :asc).select { |o| o.poll_officer? == true }
  end

  private

    def load_booth
      @booth = ::Poll::Booth.find(params[:booth_id])
    end

    def load_shifts
      @shifts = @booth.shifts
    end

    def load_officer
      if params[:officer_id].present?
        @officer = ::Poll::Officer.find(params[:officer_id])
      end
    end

    def shift_params
      shift_params = params.require(:shift).permit(:booth_id, :officer_id, :task, date: [:vote_collection_date, :recount_scrutiny_date])
      shift_params.merge(date: shift_params[:date]["#{shift_params[:task]}_date".to_sym])
    end
end
