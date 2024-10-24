class Admin::Settings::RemoteCensusTabComponent < ApplicationComponent
  def tab
    "#tab-remote-census-configuration"
  end

  def general_settings
    %w[
      remote_census.general.endpoint
    ]
  end

  def request_settings
    %w[
      remote_census.request.method_name
      remote_census.request.structure
      remote_census.request.document_type
      remote_census.request.document_number
      remote_census.request.date_of_birth
      remote_census.request.postal_code
    ]
  end

  def response_settings
    %w[
      remote_census.response.date_of_birth
      remote_census.response.postal_code
      remote_census.response.district
      remote_census.response.gender
      remote_census.response.name
      remote_census.response.surname
      remote_census.response.valid
    ]
  end
end
