module Types
  class BudgetType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :phase, String, null: true
    field :investments, Types::InvestmentType, null: false do
      argument :id, ID, required: true, default_value: false
    end

    def investments(id:)
      Budget::Investment.find(id)
    end
  end
end
