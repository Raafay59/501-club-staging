class AddMetadataToActivityLogs < ActiveRecord::Migration[8.0]
  class MigrationActivityLog < ApplicationRecord
    self.table_name = "activity_logs"
  end

  def up
    add_column :activity_logs, :content_type, :string
    add_column :activity_logs, :item_name, :text
    add_index :activity_logs, :content_type

    MigrationActivityLog.reset_column_information
    MigrationActivityLog.find_each do |log|
      metadata = infer_metadata(log.message)
      log.update_columns(content_type: metadata[:content_type], item_name: metadata[:item_name])
    end

    change_column_null :activity_logs, :content_type, false
    change_column_null :activity_logs, :item_name, false
  end

  def down
    remove_index :activity_logs, :content_type
    remove_column :activity_logs, :content_type
    remove_column :activity_logs, :item_name
  end

  private

  def infer_metadata(message)
    text = message.to_s

    if text.start_with?("Logo for ", "Photo for ")
      { content_type: "photos", item_name: extract_quoted_name(text) }
    elsif text.start_with?("Sponsor ")
      { content_type: "sponsors", item_name: extract_quoted_name(text) }
    elsif text.start_with?("Partner ")
      { content_type: "partners", item_name: extract_quoted_name(text) }
    elsif text.start_with?("Judge ")
      { content_type: "judges", item_name: extract_quoted_name(text) }
    elsif text.start_with?("Mentor ")
      { content_type: "mentors", item_name: extract_quoted_name(text) }
    elsif text.start_with?("FAQ ")
      { content_type: "faqs", item_name: extract_quoted_name(text) }
    elsif text.start_with?("Ideathon ")
      { content_type: "ideathons", item_name: extract_ideathon_year(text) }
    else
      { content_type: "activity", item_name: text }
    end
  end

  def extract_quoted_name(text)
    text[/\'([^\']+)\'/, 1] || text
  end

  def extract_ideathon_year(text)
    text[/\AIdeathon ([^ ]+) was /, 1] || text
  end
end
