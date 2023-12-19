require "rails_helper"

describe "Commenting topics from proposals" do
  it_behaves_like "flaggable", :topic_with_community_comment
end
