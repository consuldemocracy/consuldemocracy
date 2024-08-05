require "rails_helper"

describe Types::BudgetType do
  describe "#investment" do
    it "does not include hidden comments" do
      budget = create(:budget)
      investment = create(:budget_investment, budget: budget)

      create(:comment, commentable: investment, body: "Visible")
      create(:comment, :hidden, commentable: investment, body: "Hidden")

      query = <<~GRAPHQL
        {
          budget(id: #{budget.id}) {
            investment(id: #{investment.id}) {
              comments {
                edges {
                  node {
                    body
                  }
                }
              }
            }
          }
        }
      GRAPHQL

      response = execute(query)
      received_bodies = extract_fields(response, "budget.investment.comments", "body")

      expect(received_bodies).to eq ["Visible"]
    end
  end
end
