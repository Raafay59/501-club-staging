# frozen_string_literal: true

# Merges the legacy `ideathons` table (integer year PK) into `ideathon_years` (bigint id)
# and adds tables from the public Ideathon site (teams, registrations, manager logs).
class IntegrateIdeathonYearsAndPublicSite < ActiveRecord::Migration[8.0]
  def up
    create_admins_table unless table_exists?(:admins)
    ensure_ideathon_years_table
    seed_ideathon_years_from_ideathons if table_exists?(:ideathons)

    create_ideathon_events_table unless table_exists?(:ideathon_events)
    create_teams_table unless table_exists?(:teams)
    create_registered_attendees_table unless table_exists?(:registered_attendees)
    create_manager_action_logs_table unless table_exists?(:manager_action_logs)

    migrate_child_tables_to_ideathon_year_id if table_exists?(:faqs) && column_exists?(:faqs, :year)

    drop_table :ideathons if table_exists?(:ideathons)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_admins_table
    create_table :admins do |t|
      t.string :email, null: false
      t.string :full_name
      t.string :uid
      t.string :avatar_url
      t.timestamps null: false
    end
    add_index :admins, :email, unique: true
  end

  def ensure_ideathon_years_table
    unless table_exists?(:ideathon_years)
      create_table :ideathon_years do |t|
        t.integer :year, null: false
        t.string :theme
        t.string :name
        t.text :description
        t.string :location
        t.date :start_date
        t.date :end_date
        t.boolean :is_active
        t.timestamps null: false
      end
      add_index :ideathon_years, :year, unique: true
    else
      add_column :ideathon_years, :year, :integer unless column_exists?(:ideathon_years, :year)
      add_column :ideathon_years, :theme, :string unless column_exists?(:ideathon_years, :theme)
      add_index :ideathon_years, :year, unique: true unless index_exists?(:ideathon_years, :year)
    end
  end

  def seed_ideathon_years_from_ideathons
    execute <<~SQL.squish
      INSERT INTO ideathon_years (year, theme, name, description, location, start_date, end_date, is_active, created_at, updated_at)
      SELECT i.year,
             i.theme,
             'Ideathon ' || i.year::text,
             NULL,
             NULL,
             NULL,
             NULL,
             FALSE,
             i.created_at,
             i.updated_at
      FROM ideathons i
      WHERE NOT EXISTS (SELECT 1 FROM ideathon_years iy WHERE iy.year = i.year)
    SQL
  end

  def create_ideathon_events_table
    create_table :ideathon_events do |t|
      t.references :ideathon_year, null: false, foreign_key: true
      t.string :event_name
      t.text :event_description
      t.date :event_date
      t.time :event_time
      t.timestamps null: false
    end
  end

  def create_teams_table
    create_table :teams do |t|
      t.references :ideathon_year, null: false, foreign_key: true
      t.string :team_name
      t.boolean :unassigned
      t.timestamps null: false
    end
  end

  def create_registered_attendees_table
    create_table :registered_attendees do |t|
      t.references :ideathon_year, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :attendee_name
      t.string :attendee_phone
      t.string :attendee_email
      t.string :attendee_major
      t.string :attendee_class
      t.timestamps null: false
    end
  end

  def create_manager_action_logs_table
    create_table :manager_action_logs do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :action, null: false
      t.string :record_type
      t.bigint :record_id
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_address
      t.string :user_agent
      t.timestamps null: false
    end
    add_index :manager_action_logs, %i[record_type record_id]
    add_index :manager_action_logs, :action
    add_index :manager_action_logs, :created_at
  end

  def migrate_child_tables_to_ideathon_year_id
    %i[faqs rules mentors_judges sponsors_partners].each do |table|
      next unless table_exists?(table)
      next if column_exists?(table, :ideathon_year_id)

      add_reference table, :ideathon_year, null: true, foreign_key: { to_table: :ideathon_years }

      execute <<~SQL.squish
        UPDATE #{table}
        SET ideathon_year_id = ideathon_years.id
        FROM ideathon_years
        WHERE ideathon_years.year = #{table}.year
      SQL

      if foreign_key_exists?(table, :ideathons)
        remove_foreign_key table, :ideathons
      end

      remove_index table, :year if index_exists?(table, :year)

      change_column_null table, :ideathon_year_id, false
      remove_column table, :year, :integer
    end
  end
end
