class CreateMentorsJudges < ActiveRecord::Migration[8.1]
     def change
          create_table :mentors_judges, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.string :name, null: false
               t.string :job_title
               t.string :photo_url
               t.text :bio
               t.boolean :is_judge, default: false, null: false

               t.timestamps
          end

          add_index :mentors_judges, [ :ideathon_year_id, :name ], name: "index_mentors_judges_on_ideathon_year_id_and_name" unless index_exists?(:mentors_judges, [ :ideathon_year_id, :name ], name: "index_mentors_judges_on_ideathon_year_id_and_name")
     end
end
