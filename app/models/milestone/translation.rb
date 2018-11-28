class Milestone::Translation < Globalize::ActiveRecord::Translation
  delegate :status_id, to: :globalized_model
end
