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
    ["1", "2", "3"].each do |document_type|
      @residence.document_type = document_type
      if @residence.save
        voter = Poll::Voter.new(document_type:   @residence.document_type,
                                document_number: @residence.document_number,
                                user: @residence.user,
                                poll: @residence.letter_poll,
                                origin: "letter")
        if voter.save
          @log = ::Poll::LetterOfficerLog.log(current_user, voter.document_number, @residence.postal_code, :ok)
        end
      else
        if @residence.document_number.blank? || @residence.errors[:year_of_birth].present? || @residence.errors[:residence_in_madrid].present? || (not @residence.retrieve_census_data.valid?)
          @log = ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, @residence.postal_code, :census_failed)
        elsif @residence.postal_code.blank? && @residence.retrieve_census_data.valid? && (not @residence.already_voted?)
          @log = ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, @residence.postal_code, :no_postal_code, @residence.census_name, @residence.retrieve_census_data.postal_code)
        elsif @residence.errors[:document_number].present?
          @log = ::Poll::LetterOfficerLog.log(current_user, @residence.document_number, @residence.postal_code, :has_voted)
        end
      end

      break if @log.message == "Voto VÁLIDO" || @log.message == "Voto REFORMULADO" || @log.message == "Verifica EL NOMBRE"
    end

    if @log.message == "Verifica EL NOMBRE"
      redirect_to verify_name_officing_letter_path(id: @log.id)
    else
      redirect_to officing_letter_path(id: @log.id)
    end
  end

  def show
    @log = ::Poll::LetterOfficerLog.find(params[:id])
  end

  def verify_name
    @residence = Officing::Residence.new(letter: true)
    @log = ::Poll::LetterOfficerLog.find(params[:id])
  end

  private

    def verify_letter_officer
      raise CanCan::AccessDenied unless current_user.try(:poll_officer).try(:letter_officer?) || current_user.try(:administrator?)
    end

    def residence_params
      params.require(:residence).permit(:document_number, :postal_code)
    end

    def letter?
      true
    end

end
