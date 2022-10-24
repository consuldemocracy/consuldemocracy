module Cardable
  extend ActiveSupport::Concern

  included do
    has_many :cards, class_name: "Widget::Card", as: :cardable, dependent: :destroy
  end
end
