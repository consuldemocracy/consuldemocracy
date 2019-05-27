class AddHeaderColorSettingsToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :background_color, :text
    add_column :legislation_processes, :font_color, :text
  end
end
