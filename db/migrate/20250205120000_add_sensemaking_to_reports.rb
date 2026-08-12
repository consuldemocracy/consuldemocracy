# frozen_string_literal: true

class AddSensemakingToReports < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :sensemaking, :boolean, default: false
  end
end
