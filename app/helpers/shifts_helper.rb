module ShiftsHelper
  def officer_select_options(officers)
    officers.map { |officer| [officer.name, officer.id] }
  end
end
