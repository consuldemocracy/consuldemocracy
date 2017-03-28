class FailedCensusCall < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :poll_officer, class_name: 'Poll::Officer', counter_cache: true
end
