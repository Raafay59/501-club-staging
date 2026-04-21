class CreateRules < ActiveRecord::Migration[8.1]
     def change
          create_table :rules, if_not_exists: true do |t|
               t.references :ideathon_year, null: false, foreign_key: true
               t.text :rule_text, null: false

               t.timestamps
          end
     end
end
