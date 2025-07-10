require "securerandom"
require "axlsx"

namespace :data do
  namespace :budgets do
    desc "Obtener un excel con los datos de todas las votaciones"
    task final_votes: :environment do
      p = Axlsx::Package.new
      wb = p.workbook

      Budget.order(id: :asc).each do |budget|
        wb.add_worksheet(name: "Presupuesto ID #{budget.id}") do |sheet|
          sheet.add_row [
            "DOCUMENTO USUARIO",
            "ID USUARIO",
            "ID PROPUESTA",
            "NOMBRE PROPUESTA",
            "FECHA CREACIÓN USUARIO",
            "FECHA DE VOTACIÓN"
          ]

          budget_ballot_lines = Budget::Ballot::Line.joins(ballot: :user).includes(ballot: :user).where("budget_ballots.budget_id = ?", budget.id).order("budget_ballot_lines.investment_id, users.document_number")
          budget_ballot_lines.each do |budget_ballot_line|
            current_document_number = nil
            current_document_number = budget_ballot_line.ballot.user.document_number if budget_ballot_line.ballot.user.document_number.present?

            sheet.add_row [
              current_document_number,
              budget_ballot_line.ballot.user_id,
              budget_ballot_line.investment_id,
              budget_ballot_line.investment.title,
              budget_ballot_line.ballot.user.created_at.strftime("%d/%m/%Y - %H:%M"),
              budget_ballot_line.created_at.strftime("%d/%m/%Y - %H:%M")
            ]
          end
        end
      end

      p.serialize("votos_presupuestos_participativos.xlsx")
    end
  end
end
