require_dependency Rails.root.join("lib", "remote_census_api").to_s

class RemoteCensusApi
  DOCUMENT_TYPES = {
    1 => 'D',
    2 => 'P',
    3 => 'T',
    4 => 'X'
  }.freeze

  class Response
    def valid?
      path_value = Setting["remote_census.response.valid"]
      extract_value(path_value) == "SI"
    end
  end

  private

    def request(document_type, document_number, date_of_birth, postal_code)
      structure = JSON.parse(Setting["remote_census.request.structure"])
      fill_in(structure, Setting["remote_census.request.document_type"], DOCUMENT_TYPES[document_type])
      fill_in(structure, Setting["remote_census.request.document_number"], document_number)
      fill_in(structure, Setting["remote_census.request.postal_code"], postal_code)
      if date_of_birth.present?
        fill_in(structure,
                Setting["remote_census.request.date_of_birth"],
                date_of_birth.strftime("%d%m%Y"))
      end

      structure
    end
end
