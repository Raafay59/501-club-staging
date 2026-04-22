# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[8.1]
     def change
          create_table :admins, if_not_exists: true do |t|
               t.string :email, null: false
               t.string :full_name
               t.string :uid
               t.string :avatar_url

               t.timestamps null: false
          end

          add_index :admins, :email, unique: true unless index_exists?(:admins, :email)
     end
end
