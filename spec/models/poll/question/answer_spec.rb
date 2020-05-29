require "rails_helper"

describe Poll::Question::Answer do
  it_behaves_like "globalizable", :poll_question_answer
end
