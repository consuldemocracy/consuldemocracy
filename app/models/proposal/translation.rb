class Proposal::Translation < Globalize::ActiveRecord::Translation
  delegate :retire_form, to: :globalized_model
end
