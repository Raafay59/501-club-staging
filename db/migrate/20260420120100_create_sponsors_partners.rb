class CreateSponsorsPartners < ActiveRecord::Migration[8.1]
     def change
          create_table :sponsors_partners, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.string :name, null: false
               t.string :job_title
               t.string :logo_url
               t.text :blurb
               t.boolean :is_sponsor, default: false, null: false

               t.timestamps
          end

          add_index :sponsors_partners, [ :ideathon_year_id, :name ], name: "index_sponsors_partners_on_ideathon_year_id_and_name" unless index_exists?(:sponsors_partners, [ :ideathon_year_id, :name ], name: "index_sponsors_partners_on_ideathon_year_id_and_name")
     end
end
