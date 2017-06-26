module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follows, as: :followable
  end

end
