class DropBooksTable < ActiveRecord::Migration[8.1]
     def up
          drop_table :books, if_exists: true
     end

     def down
          create_table :books do |t|
               t.string :title

               t.timestamps
          end
     end
end
