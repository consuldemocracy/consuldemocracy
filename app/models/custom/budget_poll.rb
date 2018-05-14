class BudgetPoll < ActiveRecord::Base
  VALID_PREFERRED_SUBJECTS = [
    'ns/nc',
    'Fase de propuesta',
    'Fase de apoyos',
    'Fase de informes',
    'Fase de votación final',
    'Otros'
  ].freeze

  validates :name, presence: true
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :preferred_subject, inclusion: { in: VALID_PREFERRED_SUBJECTS }
end
