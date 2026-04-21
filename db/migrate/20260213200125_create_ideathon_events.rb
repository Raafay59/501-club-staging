class CreateIdeathonEvents < ActiveRecord::Migration[8.1]
     def change
          create_table :ideathon_events, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.string :event_name
               t.text :event_description
               t.date :event_date
               t.time :event_time

               t.timestamps
          end
     end
end
