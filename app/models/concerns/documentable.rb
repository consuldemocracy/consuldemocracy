module Documentable
  extend ActiveSupport::Concern

  included do
    has_many :documents, as: :documentable, dependent: :destroy
  end

end
