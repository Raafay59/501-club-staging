module ActivityLogMessage
  module_function

  IMPORT_CONFIG = {
    "Faq" => {
      content_type: "faqs",
      singular: "FAQ",
      plural: "FAQs"
    },
    "Ideathon" => {
      content_type: "ideathons",
      singular: "ideathon",
      plural: "ideathons"
    },
    "MentorsJudge" => {
      content_type: "mentors_judges",
      singular: "mentor/judge",
      plural: "mentors/judges"
    },
    "Rule" => {
      content_type: "rules",
      singular: "rule",
      plural: "rules"
    },
    "SponsorsPartner" => {
      content_type: "sponsors_partners",
      singular: "sponsor/partner",
      plural: "sponsors/partners"
    }
  }.freeze

  def entry_for(record, action, saved_changes: nil)
    case record
    when SponsorsPartner
      sponsors_partner_entry(record, action, saved_changes: saved_changes)
    when MentorsJudge
      mentors_judge_entry(record, action, saved_changes: saved_changes)
    when Faq
      faq_entry(record, action)
    when Rule
      rule_entry(record, action)
    when Ideathon
      ideathon_entry(record, action)
    end
  end

  def import_entry_for(model, count)
    config = IMPORT_CONFIG[model.to_s]
    return if config.blank?

    noun = count.to_i == 1 ? config[:singular] : config[:plural]
    {
      content_type: config[:content_type],
      item_name: "#{count} #{noun}",
      message: "Imported #{count} #{noun}"
    }
  end

  def export_entry_for(model, count)
    config = IMPORT_CONFIG[model.to_s]
    return if config.blank?

    noun = count.to_i == 1 ? config[:singular] : config[:plural]
    {
      content_type: config[:content_type],
      item_name: "#{count} #{noun}",
      message: "Exported #{count} #{noun}"
    }
  end

  def for_sponsors_partner(record, action, saved_changes: nil)
    sponsors_partner_entry(record, action, saved_changes: saved_changes)[:message]
  end

  def for_mentors_judge(record, action, saved_changes: nil)
    mentors_judge_entry(record, action, saved_changes: saved_changes)[:message]
  end

  def for_faq(record, action, saved_changes: nil)
    faq_entry(record, action)[:message]
  end

  def for_ideathon(record, action, saved_changes: nil)
    ideathon_entry(record, action)[:message]
  end

  def for_rule(record, action, saved_changes: nil)
    rule_entry(record, action)[:message]
  end

  def sponsors_partner_entry(record, action, saved_changes: nil)
    label = record.is_sponsor? ? "Sponsor" : "Partner"
    content_type = record.is_sponsor? ? "sponsors" : "partners"
    name = record.name
    message = case action.to_s
    when "added"
      "#{label} '#{name}' was added"
    when "removed"
      "#{label} '#{name}' was removed"
    when "edited"
      "#{label} '#{name}' was edited"
    end

    if action.to_s == "edited" && logo_only_change?(saved_changes)
      return {
        content_type: "photos",
        item_name: name,
        message: "Logo for #{label.downcase} '#{name}' was updated"
      }
    end

    {
      content_type: content_type,
      item_name: name,
      message: message
    }
  end

  def mentors_judge_entry(record, action, saved_changes: nil)
    role = record.is_judge? ? "Judge" : "Mentor"
    content_type = record.is_judge? ? "judges" : "mentors"
    name = record.name
    message = case action.to_s
    when "added"
      "#{role} '#{name}' was added"
    when "removed"
      "#{role} '#{name}' was removed"
    when "edited"
      "#{role} '#{name}' was edited"
    end

    if action.to_s == "edited" && photo_only_change?(saved_changes)
      return {
        content_type: "photos",
        item_name: name,
        message: "Photo for #{role.downcase} '#{name}' was updated"
      }
    end

    {
      content_type: content_type,
      item_name: name,
      message: message
    }
  end

  def faq_entry(record, action)
    question = record.question
    preview = truncate_q(question)
    message = case action.to_s
    when "added"
      "FAQ '#{preview}' was added"
    when "removed"
      "FAQ '#{preview}' was removed"
    when "edited"
      "FAQ '#{preview}' was edited"
    end

    {
      content_type: "faqs",
      item_name: question,
      message: message
    }
  end

  def ideathon_entry(record, action)
    year = record.year.to_s
    message = case action.to_s
    when "added"
      "Ideathon #{year} was added"
    when "removed"
      "Ideathon #{year} was removed"
    when "edited"
      "Ideathon #{year} was edited"
    end

    {
      content_type: "ideathons",
      item_name: year,
      message: message
    }
  end

  def rule_entry(record, action)
    text = record.rule_text.to_s
    preview = truncate_q(text)
    message = case action.to_s
    when "added"
      "Rule '#{preview}' was added"
    when "removed"
      "Rule '#{preview}' was removed"
    when "edited"
      "Rule '#{preview}' was edited"
    else
      "Rule '#{preview}' was #{action}"
    end

    {
      content_type: "rules",
      item_name: text,
      message: message
    }
  end

  def meaningful_keys(saved_changes)
    return [] if saved_changes.blank?

    saved_changes.keys.map(&:to_s) - %w[updated_at]
  end

  def logo_only_change?(saved_changes)
    meaningful_keys(saved_changes) == [ "logo_url" ]
  end

  def photo_only_change?(saved_changes)
    meaningful_keys(saved_changes) == [ "photo_url" ]
  end

  def truncate_q(text, max = 80)
    s = text.to_s.strip
    s.length > max ? "#{s[0, max]}…" : s
  end
end
