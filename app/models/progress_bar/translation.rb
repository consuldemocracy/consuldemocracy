class ProgressBar::Translation < Globalize::ActiveRecord::Translation
  delegate :primary?, to: :globalized_model
end
