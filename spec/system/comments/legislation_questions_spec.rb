require "rails_helper"

describe "Commenting legislation questions" do
  context "Concerns" do
    it_behaves_like "notifiable in-app", :legislation_question
    it_behaves_like "flaggable", :legislation_question_comment
  end
end
