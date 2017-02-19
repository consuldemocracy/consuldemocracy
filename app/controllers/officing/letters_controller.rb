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
        ::Poll::LetterOfficerLog.log(current_user, voter.document_number, :ok)
      else
        ::Poll::LetterOfficerLog.log(current_user, voter.document_number, :has_voted)
      end

      redirect_to new_officing_letter_path, notice: t("officing.letter.flash.create")
    else
      if @residence.errors[:residence_in_madrid].present?
        ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, :census_failed)
      elsif @residence.errors[:document_number].present?
        ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, :has_voted)
      end

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
