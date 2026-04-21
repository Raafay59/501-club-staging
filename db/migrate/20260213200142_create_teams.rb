class CreateTeams < ActiveRecord::Migration[8.1]
     def change
          create_table :teams, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.string :team_name
               t.boolean :unassigned

               t.timestamps
          end
     end
end
