namespace :milestones do

  def generate_table_migration_sql(new_table:, old_table:, columns:)
    from_cols = ['id', *columns.keys]
    to_cols   = ['id', *columns.values]
    <<~SQL
      INSERT INTO #{new_table} (#{to_cols.join(', ')})
      SELECT #{from_cols.join(', ')} FROM #{old_table};
    SQL
  end

  def migrate_table!(new_table:, old_table:, columns:)
    puts "Migrating data from '#{old_table}' to '#{new_table}'..."
    result = ActiveRecord::Base.connection.execute(
      generate_table_migration_sql(old_table: old_table,
                                   new_table: new_table,
                                   columns:   columns)

    )
    puts "#{result.cmd_tuples} rows affected"
  end

  def populate_column!(table:, column:, value:)
    puts "Populating column '#{column}' from table '#{table}' with '#{value}'..."
    result = ActiveRecord::Base.connection.execute(
      "UPDATE #{table} SET #{column} = '#{value}';"
    )
    puts "#{result.cmd_tuples} rows affected"
  end

  def count_rows(table)
    ActiveRecord::Base.connection.query("SELECT COUNT(*) FROM #{table};")[0][0].to_i
  end

  desc "Migrate milestones and milestone status data after making the model polymorphic"
  task migrate: :environment do
    # This script copies all milestone-related data from the old tables to
    # the new ones (preserving all primary keys). All 3 of the new tables
    # must be empty.
    #
    # To clear the new tables to test this script:
    #
    #   DELETE FROM milestone_statuses;
    #   DELETE FROM milestones;
    #   DELETE FROM milestone_translations;
    #

    start = Time.now

    ActiveRecord::Base.transaction do
      migrate_table! old_table: 'budget_investment_statuses',
                     new_table: 'milestone_statuses',
                     columns: {'name'        => 'name',
                               'description' => 'description',
                               'hidden_at'   => 'hidden_at',
                               'created_at'  => 'created_at',
                               'updated_at'  => 'updated_at'}

      migrate_table! old_table: 'budget_investment_milestones',
                     new_table: 'milestones',
                     columns: {'investment_id' => 'milestoneable_id',
                               'title'         => 'title',
                               'description'   => 'description',
                               'created_at'    => 'created_at',
                               'updated_at'    => 'updated_at',
                               'publication_date' => 'publication_date',
                               'status_id'     => 'status_id'}

      populate_column! table:  'milestones',
                       column: 'milestoneable_type',
                       value:  'Budget::Investment'

      migrate_table! old_table: 'budget_investment_milestone_translations',
                     new_table: 'milestone_translations',
                     columns: {'budget_investment_milestone_id' => 'milestone_id',
                               'locale'      => 'locale',
                               'created_at'  => 'created_at',
                               'updated_at'  => 'updated_at',
                               'title'       => 'title',
                               'description' => 'description'}

      Image.where(imageable_type: "Budget::Investment::Milestone").
            update_all(imageable_type: "Milestone")
      Document.where(documentable_type: "Budget::Investment::Milestone").
            update_all(documentable_type: "Milestone")

      puts "Verifying that all rows were copied..."

      {
        "budget_investment_milestones"             => "milestones",
        "budget_investment_statuses"               => "milestone_statuses",
        "budget_investment_milestone_translations" => "milestone_translations"
      }.each do |original_table, migrated_table|
        ActiveRecord::Base.connection.execute(
          "select setval('#{migrated_table}_id_seq', (select max(id) from #{migrated_table}));"
        )

        unless count_rows(original_table) == count_rows(migrated_table)
          raise "Number of rows of old and new tables do not match! Rolling back transaction..."
        end
      end
    end

    puts "Finished in %.3f seconds" % (Time.now - start)
  end
end
