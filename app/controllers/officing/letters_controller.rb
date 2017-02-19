class Officing::LettersController < Officing::BaseController
  skip_authorization_check
  helper_method :letter?
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
      ::Poll::LetterOfficerLog.log(current_user, voter.document_number, :census_failed)
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :postal_code)
    end

    def letter?
      true
    end
end
