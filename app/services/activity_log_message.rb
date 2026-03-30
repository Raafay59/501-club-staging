module ActivityLogMessage
  module_function

  def for_sponsors_partner(record, action, saved_changes: nil)
    label = record.is_sponsor? ? "Sponsor" : "Partner"
    name = record.name
    case action.to_s
    when "added"
      "#{label} '#{name}' was added"
    when "removed"
      "#{label} '#{name}' was removed"
    when "edited"
      if logo_only_change?(saved_changes)
        logo_label = record.is_sponsor? ? "sponsor" : "partner"
        "Logo for #{logo_label} '#{name}' was updated"
      else
        "#{label} '#{name}' was edited"
      end
    end
  end

  def for_mentors_judge(record, action, saved_changes: nil)
    role = record.is_judge? ? "Judge" : "Mentor"
    name = record.name
    case action.to_s
    when "added"
      "#{role} '#{name}' was added"
    when "removed"
      "#{role} '#{name}' was removed"
    when "edited"
      if photo_only_change?(saved_changes)
        "Photo for #{role.downcase} '#{name}' was updated"
      else
        "#{role} '#{name}' was edited"
      end
    end
  end

  def for_faq(record, action, saved_changes: nil)
    q = truncate_q(record.question)
    case action.to_s
    when "added"
      "FAQ '#{q}' was added"
    when "removed"
      "FAQ '#{q}' was removed"
    when "edited"
      "FAQ '#{q}' was edited"
    end
  end

  def for_ideathon(record, action, saved_changes: nil)
    year = record.year
    case action.to_s
    when "added"
      "Ideathon #{year} was added"
    when "removed"
      "Ideathon #{year} was removed"
    when "edited"
      "Ideathon #{year} was edited"
    end
  end

  def logo_only_change?(saved_changes)
    meaningful_keys(saved_changes) == [ "logo_url" ]
  end

  def photo_only_change?(saved_changes)
    meaningful_keys(saved_changes) == [ "photo_url" ]
  end

  def meaningful_keys(saved_changes)
    return [] if saved_changes.blank?

    saved_changes.keys.map(&:to_s) - %w[updated_at]
  end

  def truncate_q(text, max = 80)
    s = text.to_s.strip
    s.length > max ? "#{s[0, max]}…" : s
  end
end
