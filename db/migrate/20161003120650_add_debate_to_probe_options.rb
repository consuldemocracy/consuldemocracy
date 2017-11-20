class AddDebateToProbeOptions < ActiveRecord::Migration
  def change
    add_reference :probe_options, :debate, index: true, foreign_key: true
  end
end
