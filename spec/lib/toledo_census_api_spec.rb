require 'rails_helper'

#TOL-2 Spec for Toledo Custom Census API
describe ToledoCensusApi do

  let(:api) {described_class.new}

  describe '#get_document_number_variants' do
    it "trims and cleans up entry" do
      expect(api.get_document_number_variants(2, '  1 2@ 34')).to eq(['1234'])
    end

    it "returns only one try for passports & residence cards" do
      expect(api.get_document_number_variants(2, '1234')).to eq(['1234'])
      expect(api.get_document_number_variants(3, '1234')).to eq(['1234'])
    end

    it 'takes only the last 8 digits for dnis and resicence cards' do
      expect(api.get_document_number_variants(1, '543212345678')).to eq(['12345678'])
    end

    it 'tries all the dni variants padding with zeroes' do
      expect(api.get_document_number_variants(1, '0123456')).to eq(['123456', '0123456', '00123456'])
      expect(api.get_document_number_variants(1, '00123456')).to eq(['123456', '0123456', '00123456'])
    end

    it 'adds upper and lowercase letter when the letter is present' do
      expect(api.get_document_number_variants(1, '1234567A')).to eq(%w(1234567 01234567 1234567a 1234567A 01234567a 01234567A))
    end
  end

  describe '#residence' do

    let(:valid_response) do
      {
        'IDHAB' => '111111',
        'DNI' => '01234567',
        'Nombre' => 'Doménikos',
        'PrimerApellido' => 'Theotokópoulo',
        'SegundoApellido' => 'ElGreco',
        'FechaNacimiento' => '1992-11-01 00:00:00',
        'Telefono' => '666666666',
        'Barrio' => 'CENTRO',
        'Barrio_ID'=> '08',
        'CP' => '45003'
      }
    end

    let(:invalid_response) do
      {
        error:
          {
            code: 404,
            message: '404 Not Found'
          }
      }
    end

    it "Valid response" do
      allow(api).to receive(:get_response_body).with(1, '001234567').and_return(invalid_response)
      allow(api).to receive(:get_response_body).with(1, '1234567').and_return(invalid_response)
      expect(api).to receive(:get_response_body).with(1, '01234567').and_return(valid_response)

      response = api.call(1, '01234567')
      expect(response).to be_valid
      expect(response.valid?).to be true

      expect(response.postal_code).to eq('45003')
      expect(response.name).to eq('Doménikos Theotokópoulo ElGreco')
      expect(response.date_of_birth).to eq(Date.new(1992, 11, 01))

    end

    it "Invalid response" do
      expect(api).to receive(:get_response_body).with(1, '1234567').and_return(invalid_response)
      expect(api).to receive(:get_response_body).with(1, '01234567').and_return(invalid_response)

      response = api.call(1, '1234567')
      expect(response).to_not be_valid
      expect(response.valid?).to be false

    end

  end

end
