class AddSubtitleToProjectPhaseTranslations < ActiveRecord::Migration[7.0]
  def change
    add_column :project_phase_translations, :subtitle, :string, if_not_exists: true
  end
end
