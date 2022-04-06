require "savon/mock/spec_helper"

module RemoteCensusMock
  include Savon::SpecHelper
  include DocumentParser

  def mock_valid_remote_census_response
    mock_remote_census_response(File.read("spec/fixtures/files/remote_census_api/valid.xml"))
  end

  def mock_invalid_remote_census_response
    mock_remote_census_response(File.read("spec/fixtures/files/remote_census_api/invalid.xml"))
  end

  def mock_invalid_signature_sheet_remote_census_response
    xml = File.read("spec/fixtures/files/remote_census_api/invalid.xml")

    Signature.new.document_types.each do |document_type|
      get_document_number_variants(document_type, "12345678Z").each do
        mock_remote_census_response(xml)
      end
    end
  end

  def mock_remote_census_response(xml)
    savon.expects(Setting["remote_census.request.method_name"].to_sym)
         .with(message: :any)
         .returns(xml)
  end
end
