module Linkable
  extend ActiveSupport::Concern

  included do
    has_many :links, as: :linkable, inverse_of: :linkable, dependent: :destroy
    accepts_nested_attributes_for :links, allow_destroy: true
  end
end
