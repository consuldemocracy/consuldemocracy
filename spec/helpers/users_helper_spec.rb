require 'rails_helper'

describe UsersHelper do

  describe '#humanize_document_type' do
    it "should return a humanized document type" do
      expect(humanize_document_type("1")).to eq "DNI"
      expect(humanize_document_type("2")).to eq "Passport"
      expect(humanize_document_type("3")).to eq "Residence card"
    end
  end

end
