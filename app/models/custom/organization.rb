require_dependency Rails.root.join('app', 'models', 'organization').to_s

class  Organization

  validates :responsible_document_number, presence: true, uniqueness: true
end