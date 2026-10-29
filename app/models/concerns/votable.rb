module Votable
  extend ActiveSupport::Concern

  included do
    acts_as_votable
  end
end
