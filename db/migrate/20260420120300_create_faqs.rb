class CreateFaqs < ActiveRecord::Migration[8.1]
     def change
          create_table :faqs, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.text :question, null: false
               t.text :answer, null: false

               t.timestamps
          end
     end
end
