module Types
  class BudgetType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :phase, String, null: true
    field :investments, Types::BudgetInvestmentType.connection_type, "Returns all investments", null: false
    object_by_id_field :investment, Types::BudgetInvestmentType, "Returns investment for ID", null: false

    def investments
      Budget::Investment.public_for_api
    end

    def investment(id:)
      investments.find(id)
    end
  end
end
