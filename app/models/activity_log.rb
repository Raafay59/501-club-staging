class ActivityLog < ApplicationRecord
  belongs_to :user

  ACTIONS = %w[added edited imported removed].freeze
  CONTENT_TYPES = %w[
    activity
    faqs
    ideathons
    judges
    mentors
    mentors_judges
    partners
    photos
    sponsors
    sponsors_partners
  ].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :content_type, inclusion: { in: CONTENT_TYPES }
  validates :item_name, presence: true
  validates :message, presence: true

  before_update :prevent_changes
  before_destroy :prevent_deletion

  def self.record!(user:, action:, message:, content_type: nil, item_name: nil)
    metadata = infer_metadata(message)

    create!(
      user: user,
      action: action.to_s,
      content_type: content_type.presence || metadata[:content_type],
      item_name: item_name.presence || metadata[:item_name],
      message: message
    )
  end

  def self.safe_record(**attributes)
    record!(**attributes)
  rescue StandardError => error
    Rails.logger.error("Activity log failed: #{error.class}: #{error.message}")
    nil
  end

  def self.record_change(record:, action:, saved_changes: nil, user: Current.user)
    return if user.blank?

    entry = ActivityLogMessage.entry_for(record, action, saved_changes: saved_changes)
    return if entry.blank?

    safe_record(user: user, action: action, **entry)
  end

  def self.record_import(model:, count:, user: Current.user)
    return if user.blank? || count.to_i.zero?

    entry = ActivityLogMessage.import_entry_for(model, count)
    return if entry.blank?

    safe_record(user: user, action: :imported, **entry)
  end

  def self.infer_metadata(message)
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

  def self.extract_quoted_name(text)
    text[/\'([^\']+)\'/, 1] || text
  end

  def self.extract_ideathon_year(text)
    text[/\AIdeathon ([^ ]+) was /, 1] || text
  end

  private

  def prevent_changes
    errors.add(:base, "Activity logs are immutable")
    throw :abort
  end

  def prevent_deletion
    errors.add(:base, "Activity logs are immutable")
    throw :abort
  end
end
