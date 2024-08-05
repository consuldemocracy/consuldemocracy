module Types
  class BudgetType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :phase, String, null: true
    field :investments, Types::BudgetInvestmentType.connection_type, "Returns all investments", null: false
    field :investment, Types::BudgetInvestmentType, null: false do
      argument :id, ID, required: true, default_value: false
    end

    def investments
      Budget::Investment.public_for_api
    end

    def investment(id:)
      investments.find(id)
    end
  end
end
