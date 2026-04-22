class CreateRegisteredAttendees < ActiveRecord::Migration[8.1]
     def change
          create_table :registered_attendees, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.references :team, null: false, foreign_key: true
               t.string :attendee_name
               t.string :attendee_phone
               t.string :attendee_email
               t.string :attendee_major
               t.string :attendee_class

               t.timestamps
          end
     end
end
