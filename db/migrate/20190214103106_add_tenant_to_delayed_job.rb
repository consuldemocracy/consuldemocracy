class AddTenantToDelayedJob < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :tenant, :string
  end
end
