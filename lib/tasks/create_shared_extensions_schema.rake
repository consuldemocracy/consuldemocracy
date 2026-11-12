require Rails.root.join("db/migrate/20200602233844_create_shared_extensions_schema.rb")

module AlwaysCreateSharedExtensionsSchema
  def load_schema(...)
    CreateSharedExtensionsSchema.new.up
    super
  end
end

ActiveRecord::Tasks::DatabaseTasks.prepend(AlwaysCreateSharedExtensionsSchema)
