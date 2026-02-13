class Admin::SignatureSheets::ShowComponent < ApplicationComponent
  attr_reader :signature_sheet

  def initialize(signature_sheet)
    @signature_sheet = signature_sheet
  end

  private

    def voted_signatures
      Vote.where(signature: signature_sheet.signatures.verified).count
    end
end
