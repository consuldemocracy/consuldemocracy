class Verification::Management::ManagedUser
  include ActiveModel::Model

  def self.find(document_type, document_number)
    User.where.not(document_number: nil).
    find_or_initialize_by(document_type:   document_type,
                          document_number: document_number)
  end
end
