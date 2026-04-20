# frozen_string_literal: true

class HardenIdeathonDataIntegrity < ActiveRecord::Migration[8.0]
  def up
    normalize_ideathon_years
    normalize_teams

    add_index :ideathon_years,
      :is_active,
      unique: true,
      where: "is_active = TRUE",
      name: "index_ideathon_years_single_active" unless index_exists?(:ideathon_years, :is_active, name: "index_ideathon_years_single_active")

    add_index :teams,
      :ideathon_year_id,
      unique: true,
      where: "unassigned = TRUE",
      name: "index_teams_one_unassigned_per_year" unless index_exists?(:teams, :ideathon_year_id, name: "index_teams_one_unassigned_per_year")

    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS index_teams_unique_name_per_year
      ON teams (ideathon_year_id, LOWER(team_name))
      WHERE unassigned = FALSE;
    SQL

    add_check_constraint :teams,
      "(unassigned = TRUE) OR (char_length(btrim(team_name)) > 0)",
      name: "teams_named_when_not_unassigned" unless check_constraint_exists?(:teams, name: "teams_named_when_not_unassigned")

    change_column_default :ideathon_years, :is_active, from: nil, to: false
    change_column_null :ideathon_years, :is_active, false

    change_column_default :teams, :unassigned, from: nil, to: false
    change_column_null :teams, :unassigned, false
  end

  def down
    remove_check_constraint :teams, name: "teams_named_when_not_unassigned" if check_constraint_exists?(:teams, name: "teams_named_when_not_unassigned")

    execute <<~SQL
      DROP INDEX IF EXISTS index_teams_unique_name_per_year;
    SQL

    remove_index :teams, name: "index_teams_one_unassigned_per_year" if index_exists?(:teams, :ideathon_year_id, name: "index_teams_one_unassigned_per_year")
    remove_index :ideathon_years, name: "index_ideathon_years_single_active" if index_exists?(:ideathon_years, :is_active, name: "index_ideathon_years_single_active")

    change_column_default :ideathon_years, :is_active, from: false, to: nil
    change_column_default :teams, :unassigned, from: false, to: nil
  end

  private

  def normalize_ideathon_years
    execute <<~SQL
      UPDATE ideathon_years
      SET is_active = FALSE
      WHERE is_active IS NULL;
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               ROW_NUMBER() OVER (ORDER BY year DESC, created_at DESC, id DESC) AS rn
        FROM ideathon_years
        WHERE is_active = TRUE
      )
      UPDATE ideathon_years i
      SET is_active = FALSE
      FROM ranked r
      WHERE i.id = r.id
        AND r.rn > 1;
    SQL
  end

  def normalize_teams
    execute <<~SQL
      UPDATE teams
      SET unassigned = FALSE
      WHERE unassigned IS NULL;
    SQL

    execute <<~SQL
      UPDATE teams
      SET team_name = btrim(team_name)
      WHERE team_name IS NOT NULL;
    SQL

    execute <<~SQL
      UPDATE teams
      SET team_name = 'Unassigned'
      WHERE unassigned = TRUE
        AND (team_name IS NULL OR btrim(team_name) = '');
    SQL

    execute <<~SQL
      UPDATE teams
      SET team_name = 'Team ' || id::text
      WHERE unassigned = FALSE
        AND (team_name IS NULL OR btrim(team_name) = '');
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               ideathon_year_id,
               ROW_NUMBER() OVER (
                 PARTITION BY ideathon_year_id, LOWER(btrim(team_name))
                 ORDER BY id
               ) AS rn
        FROM teams
        WHERE unassigned = FALSE
      )
      UPDATE teams t
      SET team_name = btrim(t.team_name) || ' (' || t.id::text || ')'
      FROM ranked r
      WHERE t.id = r.id
        AND r.rn > 1;
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               ideathon_year_id,
               ROW_NUMBER() OVER (PARTITION BY ideathon_year_id ORDER BY id) AS rn
        FROM teams
        WHERE unassigned = TRUE
      ),
      canonical AS (
        SELECT ideathon_year_id, id AS keep_id
        FROM ranked
        WHERE rn = 1
      ),
      duplicates AS (
        SELECT r.id AS duplicate_id, c.keep_id
        FROM ranked r
        INNER JOIN canonical c ON c.ideathon_year_id = r.ideathon_year_id
        WHERE r.rn > 1
      )
      UPDATE registered_attendees ra
      SET team_id = d.keep_id
      FROM duplicates d
      WHERE ra.team_id = d.duplicate_id;
    SQL

    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               ideathon_year_id,
               ROW_NUMBER() OVER (PARTITION BY ideathon_year_id ORDER BY id) AS rn
        FROM teams
        WHERE unassigned = TRUE
      )
      DELETE FROM teams t
      USING ranked r
      WHERE t.id = r.id
        AND r.rn > 1;
    SQL
  end
end
