class AddProjectToDesignEvents < ActiveRecord::Migration
  def change
    add_reference :design_events, :project, index: true, foreign_key: true
  end
end
