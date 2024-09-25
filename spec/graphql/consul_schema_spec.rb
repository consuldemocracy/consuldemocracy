require "rails_helper"

describe ConsulSchema do
  let(:user) { create(:user) }

  it "returns an error for queries exceeding max depth" do
    query = <<~GRAPHQL
      {
        user(id: #{user.id}) {
          public_proposals {
            edges {
              node {
                public_author {
                  username
                  public_proposals {
                    edges {
                      node {
                        public_author {
                          username
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL

    response = execute(query)

    expect(response["errors"]).not_to be nil
    expect(response["errors"].first["message"]).to match(/exceeds max depth/)
  end
end
