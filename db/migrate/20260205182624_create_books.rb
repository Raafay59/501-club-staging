class CreateBooks < ActiveRecord::Migration[8.0]
     def change
          create_table :books, if_not_exists: true do |t|
               t.string :title

               t.timestamps
          end
     end
end
