class Answer < ApplicationRecord
  CONTEXTS = ['Derechos Humanos']
  validates :text, length: { in: 10..6000 }
  validates :context, inclusion: { in: CONTEXTS }
  validates :author_id, presence: true

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
end
