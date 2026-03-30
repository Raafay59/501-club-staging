class ActivityLog < ApplicationRecord
  belongs_to :user

  ACTIONS = %w[added edited removed].freeze
  CONTENT_TYPE_FILTERS = {
    "faqs" => {
      label: "FAQs",
      patterns: [ "FAQ %" ]
    },
    "ideathons" => {
      label: "Ideathons",
      patterns: [ "Ideathon %" ]
    },
    "judges" => {
      label: "Judges",
      patterns: [ "Judge %" ]
    },
    "mentors" => {
      label: "Mentors",
      patterns: [ "Mentor %" ]
    },
    "partners" => {
      label: "Partners",
      patterns: [ "Partner %" ]
    },
    "photos" => {
      label: "Photos",
      patterns: [ "Logo for %", "Photo for %" ]
    },
    "sponsors" => {
      label: "Sponsors",
      patterns: [ "Sponsor %" ]
    }
  }.freeze
  DATE_RANGE_OPTIONS = [
    [ "All time", "" ],
    [ "Last 7 days", "last_7_days" ],
    [ "Custom date range", "custom" ]
  ].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :message, presence: true

  def self.record!(user:, action:, message:)
    create!(user: user, action: action.to_s, message: message)
  end

  def self.filter(params = {})
    filters = params.to_h.symbolize_keys.slice(:content_type, :date_range, :start_date, :end_date)
    logs = includes(:user).order(created_at: :desc)
    logs = apply_content_type_filter(logs, filters[:content_type])
    logs = apply_date_range_filter(logs, filters[:date_range], filters[:start_date], filters[:end_date])
    logs.limit(500)
  end

  def self.content_type_options
    CONTENT_TYPE_FILTERS.map { |key, config| [ config[:label], key ] }
  end

  def self.filters_active?(params = {})
    filters = params.to_h.symbolize_keys.slice(:content_type, :date_range, :start_date, :end_date)
    filters.values.any?(&:present?)
  end

  def self.apply_content_type_filter(logs, content_type)
    patterns = CONTENT_TYPE_FILTERS.dig(content_type.to_s, :patterns)
    return logs if patterns.blank?

    conditions = Array.new(patterns.length, "message LIKE ?").join(" OR ")
    logs.where(conditions, *patterns)
  end

  def self.apply_date_range_filter(logs, date_range, start_date, end_date)
    case date_range.to_s
    when "last_7_days"
      logs.where(created_at: 7.days.ago.beginning_of_day..Time.current.end_of_day)
    when "custom"
      start_on = parse_filter_date(start_date)
      end_on = parse_filter_date(end_date)
      return logs if start_on.blank? && end_on.blank?
      return logs.none if start_on.present? && end_on.present? && start_on > end_on

      range_start = start_on&.beginning_of_day || Time.zone.at(0)
      range_end = end_on&.end_of_day || Time.current.end_of_day
      logs.where(created_at: range_start..range_end)
    else
      logs
    end
  end

  def self.parse_filter_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end
end
