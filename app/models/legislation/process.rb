class Legislation::Process < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :draft_versions, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_process_id'
  has_many :questions, class_name: 'Legislation::Question', foreign_key: 'legislation_process_id'

  validates :title, presence: true
  validates :description, presence: true
  validates :target, presence: true
  validates :how_to_participate, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :debate_start_date, presence: true
  validates :debate_end_date, presence: true
  validates :draft_publication_date, presence: true
  validates :allegations_start_date, presence: true
  validates :allegations_end_date, presence: true
  validates :final_publication_date, presence: true

  scope :open, -> {where("start_date <= ? and end_date >= ?", Time.current, Time.current) }
  scope :next, -> {where("start_date > ?", Time.current) }
  scope :past, -> {where("end_date < ?", Time.current) }
end
