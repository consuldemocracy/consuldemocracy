class CreateVolunteerPolls < ActiveRecord::Migration
  def change
    create_table :volunteer_polls do |t|
      t.string :email
      t.string :availability_week
      t.string :availability_weekend
      t.string :turns
      t.boolean :any_district
      t.boolean :arganzuela
      t.boolean :barajas
      t.boolean :carabanchel
      t.boolean :centro
      t.boolean :chamartin
      t.boolean :chamberi
      t.boolean :ciudad_lineal
      t.boolean :fuencarral_el_pardo
      t.boolean :hortaleza
      t.boolean :latina
      t.boolean :moncloa_aravaca
      t.boolean :moratalaz
      t.boolean :puente_de_vallecas
      t.boolean :retiro
      t.boolean :salamanca
      t.boolean :san_blas_canillejas
      t.boolean :tetuan
      t.boolean :usera
      t.boolean :vicalvaro
      t.boolean :villa_de_vallecas
      t.boolean :villaverde
    end
  end
end
