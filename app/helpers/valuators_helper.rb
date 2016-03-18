module ValuatorsHelper

  def valuator_label(valuator)
    truncate([valuator.name, valuator.email, valuator.description].compact.join(' - '), length: 100)
  end

end