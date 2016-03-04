module ValuationHelper

  def valuator_select_options(valuator=nil)
    if valuator.present?
      Valuator.where.not(id: valuator.id).order('users.username asc').includes(:user).collect { |v| [ v.name, v.id ] }.prepend([valuator.name, valuator.id])
    else
      Valuator.all.order('users.username asc').includes(:user).collect { |v| [ v.name, v.id ] }
    end
  end

end