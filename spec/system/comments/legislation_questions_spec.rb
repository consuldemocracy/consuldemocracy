require "rails_helper"

describe "Commenting legislation questions" do
  it_behaves_like "notifiable in-app", :legislation_question
end
