class CreateIdeathonYears < ActiveRecord::Migration[8.1]
     def change
          create_table :ideathon_years, if_not_exists: true do |t|
               t.string :name
               t.text :description
               t.string :location
               t.date :start_date
               t.date :end_date
               t.boolean :is_active

               t.timestamps
          end
     end
end
