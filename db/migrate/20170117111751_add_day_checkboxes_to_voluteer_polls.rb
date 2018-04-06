class AddDayCheckboxesToVoluteerPolls < ActiveRecord::Migration
  def change
    add_column :volunteer_polls, :monday_13_morning, :boolean
    add_column :volunteer_polls, :monday_13_afternoon, :boolean

    add_column :volunteer_polls, :tuesday_14_morning, :boolean
    add_column :volunteer_polls, :tuesday_14_afternoon, :boolean

    add_column :volunteer_polls, :wednesday_15_morning, :boolean
    add_column :volunteer_polls, :wednesday_15_afternoon, :boolean

    add_column :volunteer_polls, :thursday_16_morning, :boolean
    add_column :volunteer_polls, :thursday_16_afternoon, :boolean

    add_column :volunteer_polls, :friday_17_morning, :boolean
    add_column :volunteer_polls, :friday_17_afternoon, :boolean

    add_column :volunteer_polls, :saturday_18_morning, :boolean
    add_column :volunteer_polls, :saturday_18_afternoon, :boolean

    add_column :volunteer_polls, :sunday_19_morning, :boolean
    add_column :volunteer_polls, :sunday_19_afternoon, :boolean

    add_column :volunteer_polls, :monday_20_morning, :boolean
  end
end
