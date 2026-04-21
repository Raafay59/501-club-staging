# frozen_string_literal: true

class TeamsUnassignedConstraints < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE teams SET unassigned = false WHERE unassigned IS NULL"
    change_column_default :teams, :unassigned, from: nil, to: false
    change_column_null :teams, :unassigned, false
    add_index :teams, :ideathon_year_id,
      unique: true,
      where: "unassigned = true",
      name: "index_teams_one_unassigned_per_ideathon_year"
  end

  def down
    remove_index :teams, name: "index_teams_one_unassigned_per_ideathon_year"
    change_column_null :teams, :unassigned, true
    change_column_default :teams, :unassigned, from: false, to: nil
  end
end
