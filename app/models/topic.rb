class Topic < ActiveRecord::Base
  belongs_to :community
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
end
