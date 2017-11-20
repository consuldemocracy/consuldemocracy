class VolunteerPollsController < ApplicationController

  skip_authorization_check

  def new
    @volunteer_poll = VolunteerPoll.new
  end

  def create
    @volunteer_poll = VolunteerPoll.create(volunteer_poll_params)

    if @volunteer_poll.save
      redirect_to thanks_volunteer_poll_path
    else
      render :new
    end
  end

  def thanks
  end

  private

    def volunteer_poll_params
      fields = [:email, :first_name, :last_name, :document_number, :phone, :turns] + VolunteerPoll::VALID_DAYS + VolunteerPoll::DISTRICTS
      params.require(:volunteer_poll).permit(*fields)
    end

end
