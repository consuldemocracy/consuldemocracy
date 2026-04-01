load Rails.root.join("app", "controllers", "admin", "budget_investments_controller.rb")

class Admin::BudgetInvestmentsController
  def index
    # TODO: intentar no sobreescribir por completo el método
    load_tags
    respond_to do |format|
      format.html
      format.csv do
        send_data Budget::Investment::Exporter.new(@investments).to_csv,
                  filename: "budget_investments.csv"
      end
      format.xlsx do
        response.headers["Content-Disposition"] = 'attachment; filename="Propuestas de inversión.xlsx"'
      end
    end
  end

  private

    def load_investments
      # Override the method to allow xlsx export without pagination
      @investments = Budget::Investment.scoped_filter(params, @current_filter).order_filter(params)
      @investments = Kaminari.paginate_array(@investments) if @investments.is_a?(Array)
      @investments = @investments.page(params[:page]) unless request.format.csv? || request.format.xlsx?
    end
end
