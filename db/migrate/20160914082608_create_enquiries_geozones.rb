class CreateEnquiriesGeozones < ActiveRecord::Migration
  def change
    create_table :enquiries_geozones do |t|
      t.references :enquiry, index: true, foreign_key: true
      t.references :geozone, index: true, foreign_key: true
    end
  end
end
