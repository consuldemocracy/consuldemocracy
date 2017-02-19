class Officing::LettersController < Officing::BaseController
  skip_authorization_check
  helper_method :letter?
  before_action :verify_letter_officer

  layout 'letter_officer'

  def new
    @residence = Officing::Residence.new(letter: true)
  end

  def create
    @residence = Officing::Residence.new(residence_params.merge(officer: current_user.poll_officer, letter: true))
    if @residence.save
      voter = Poll::Voter.new(document_type:   @residence.document_type,
                              document_number: @residence.document_number,
                              user: @residence.user,
                              poll: @residence.letter_poll,
                              origin: "letter")
      voter.save!
      redirect_to new_officing_letter_path, notice: t("officing.letter.flash.create")
    else
      render :new
    end
  end

  private

    def verify_letter_officer
      raise CanCan::AccessDenied unless current_user.try(:poll_officer).try(:letter_officer?) || current_user.try(:administrator?)
    end

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :postal_code)
    end

    def letter?
      true
    end

end
