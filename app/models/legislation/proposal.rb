class Legislation::Proposal < Proposal
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'

  scope :sorted, -> { order('id ASC') }
end
