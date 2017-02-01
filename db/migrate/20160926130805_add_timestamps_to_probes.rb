class AddTimestampsToProbes < ActiveRecord::Migration
  def change
    add_timestamps(:probes, null: true)
    add_timestamps(:probe_selections, null: true)
  end
end
