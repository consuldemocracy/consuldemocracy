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
      if voter.save
        log = ::Poll::LetterOfficerLog.log(current_user, voter.document_number, @residence.postal_code, :ok)
      end
    else
      if @residence.errors[:postal_code].present? || @residence.errors[:residence_in_madrid].present?
        log = ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, @residence.postal_code, :census_failed)
      elsif @residence.errors[:document_number].present?
        log = ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, @residence.postal_code, :has_voted)
      end
    end

    redirect_to officing_letter_path(id: log.id)
  end

  def show
    @log = ::Poll::LetterOfficerLog.find(params[:id])
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
