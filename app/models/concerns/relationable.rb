module Relationable
  extend ActiveSupport::Concern

  included do
    has_many :related_contents, as: :parent_relationable
  end
end
