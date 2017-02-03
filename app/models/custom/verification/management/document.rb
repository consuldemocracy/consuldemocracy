require_dependency Rails.root.join('app', 'models', 'verification', 'management', 'document').to_s

class Verification::Management::Document

  def in_census?
    response = PadronCastellonApi.new.call(document_type, document_number)
    response.valid? && valid_age?(response)
  end

end
