class ActivityLog < ApplicationRecord
     belongs_to :admin, optional: true

     after_create_commit :email_organizers

     ACTIONS = %w[added edited removed imported exported].freeze
     CONTENT_TYPE_FILTERS = {
      "faqs" => { label: "FAQs", content_types: [ "faqs" ] },
      "ideathons" => { label: "Ideathons", content_types: [ "ideathons" ] },
      "judges" => { label: "Judges", content_types: [ "judges", "mentors_judges" ] },
      "mentors" => { label: "Mentors", content_types: [ "mentors", "mentors_judges" ] },
      "partners" => { label: "Partners", content_types: [ "partners", "sponsors_partners" ] },
      "photos" => { label: "Photos", content_types: [ "photos" ] },
      "rules" => { label: "Rules", content_types: [ "rules" ] },
      "sponsors" => { label: "Sponsors", content_types: [ "sponsors", "sponsors_partners" ] }
     }.freeze
     DATE_RANGE_OPTIONS = [
       [ "All time", "" ],
       [ "Last 7 days", "last_7_days" ],
       [ "Custom date range", "custom" ]
     ].freeze
     CONTENT_TYPES = %w[
       activity
       faqs
       ideathons
       judges
       mentors
       mentors_judges
       partners
       photos
       rules
       sponsors
       sponsors_partners
     ].freeze

     validates :action, inclusion: { in: ACTIONS }
     validates :content_type, inclusion: { in: CONTENT_TYPES }
     validates :item_name, presence: true
     validates :message, presence: true

     before_update :prevent_changes
     before_destroy :prevent_deletion

     def self.record!(admin:, action:, message:, content_type: nil, item_name: nil)
          metadata = infer_metadata(message)

          create!(
            admin: admin,
            actor_name: admin.full_name.presence || admin.email,
            actor_email: admin.email,
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

     def self.record_change(record:, action:, saved_changes: nil, admin: Current.admin)
          return if admin.blank?

          entry = ActivityLogMessage.entry_for(record, action, saved_changes: saved_changes)
          return if entry.blank?

          safe_record(admin: admin, action: action, **entry)
     end

     def self.record_import(model:, count:, admin: Current.admin)
          return if admin.blank? || count.to_i.zero?

          entry = ActivityLogMessage.import_entry_for(model, count)
          return if entry.blank?

          safe_record(admin: admin, action: :imported, **entry)
     end

     def self.record_export(model:, count:, admin: Current.admin)
          return if admin.blank? || count.to_i.zero?

          entry = ActivityLogMessage.export_entry_for(model, count)
          return if entry.blank?

          safe_record(admin: admin, action: :exported, **entry)
     end

     def self.filter(params = {})
          filters = params.to_h.symbolize_keys.slice(:content_type, :date_range, :start_date, :end_date)
          logs = includes(:admin).order(created_at: :desc)
          logs = apply_content_type_filter(logs, filters[:content_type])
          logs = apply_date_range_filter(logs, filters[:date_range], filters[:start_date], filters[:end_date])
          logs.limit(500)
     end

     def actor_display_name
          actor_name.presence || admin&.full_name.presence || actor_email.presence || admin&.email.presence || "Deleted User"
     end

     def self.content_type_options
          CONTENT_TYPE_FILTERS.map { |key, config| [ config[:label], key ] }
     end

     def self.filters_active?(params = {})
          filters = params.to_h.symbolize_keys.slice(:content_type, :date_range, :start_date, :end_date)
          filters.values.any?(&:present?)
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

     def self.apply_content_type_filter(logs, content_type)
          selected_types = CONTENT_TYPE_FILTERS.dig(content_type.to_s, :content_types)
          return logs if selected_types.blank?

          logs.where(content_type: selected_types)
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

  private

       def prevent_changes
            errors.add(:base, "Activity logs are immutable")
            throw :abort
       end

       def prevent_deletion
            errors.add(:base, "Activity logs are immutable")
            throw :abort
       end

       def email_organizers
            return unless defined?(CrudMailer)

            Admin.where(role: [ "admin", "editor" ]).find_each do |recipient|
                 CrudMailer.with(
                   user: recipient,
                   change_type: action.to_s,
                   actor: admin,
                   change_message: message,
                   item_name: item_name,
                   changed_at: created_at
                 ).record_change_email.deliver_later
            rescue StandardError => error
                 Rails.logger.error("Activity log email failed for admin #{recipient.id}: #{error.class}: #{error.message}")
            end
       end
end
