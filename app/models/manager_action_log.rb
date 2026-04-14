class ManagerActionLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true

  scope :recent_first, -> { order(created_at: :desc) }

  def action_label
    a = action.to_s
    return "Exported" if a.start_with?("export.")
    return "Created" if a.end_with?(".created")
    return "Updated" if a.end_with?(".updated")
    return "Deleted" if a.end_with?(".deleted")
    a.tr(".", " ").tr("_", " ").split.map(&:capitalize).join(" ")
  end

  def target_label
    a = action.to_s
    return "Export" if a.start_with?("export.")
    return "Attendee" if a.start_with?("attendee.")
    return "Event" if a.start_with?("event.")
    record_type.to_s.presence || "—"
  end

  def record_label
    if action.to_s.start_with?("export.")
      return "Participants CSV" if action.to_s.include?("participants")
      return "Teams CSV" if action.to_s.include?("teams")
      return "CSV"
    end

    metadata_name = metadata.is_a?(Hash) ? metadata["record_name"].presence : nil
    return metadata_name if metadata_name.present?

    fallback = if metadata.is_a?(Hash)
      metadata["attendee_name"].presence || metadata["event_name"].presence
    end
    return fallback if fallback.present?

    return nil if record_type.blank? || record_id.blank?
    "#{record_type}##{record_id}"
  end

  def details_label
    return "#{metadata["count"]} rows" if metadata.is_a?(Hash) && metadata["count"].present?

    if action.to_s.end_with?(".updated")
      summary = summarize_changes_with_diffs
      return summary if summary.present?
    end

    "—"
  end

  private

  def summarize_changes_with_diffs
    return nil unless metadata.is_a?(Hash)
    changes = metadata["changes"]
    return nil unless changes.is_a?(Hash) && changes.any?

    allowed = %w[event_name event_description event_date event_time attendee_name attendee_email attendee_phone attendee_major attendee_class team_id]
    chunks = []

    changes.slice(*allowed).each do |attr, pair|
      next unless pair.is_a?(Array) && pair.length == 2
      old_val, new_val = pair
      next if old_val == new_val

      label = human_attr(attr)
      old_str = normalize_value(old_val)
      new_str = normalize_value(new_val)
      next if new_str.blank?

      chunks << "#{label}: #{truncate_value(old_str)} → #{truncate_value(new_str)}"
    end

    chunks.first(3).join(" · ").presence
  end

  def human_attr(attr)
    case attr.to_s
    when "attendee_name" then "Name"
    when "attendee_email" then "Email"
    when "attendee_phone" then "Phone"
    when "attendee_major" then "Major"
    when "attendee_class" then "Class"
    when "team_id" then "Team"
    when "event_name" then "Title"
    when "event_description" then "Description"
    when "event_date" then "Date"
    when "event_time" then "Time"
    else attr.to_s.tr("_", " ").split.map(&:capitalize).join(" ")
    end
  end

  def normalize_value(value)
    return "" if value.nil?
    s = value.is_a?(String) ? value.strip : value.to_s
    s
  end

  def truncate_value(value)
    s = value.to_s
    return "—" if s.blank?
    return s if s.length <= 80
    "#{s.first(77)}..."
  end
end
