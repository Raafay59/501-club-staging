module ApplicationHelper
  # Rules store a single text field; two paragraphs (blank line) => title + description on the public page.
  def rule_title_and_body(rule)
    text = rule.rule_text.to_s.strip
    parts = text.split(/\n\n+/, 2)
    if parts.length == 2 && parts[0].present? && parts[1].present?
      { title: parts[0].strip, body: parts[1].strip }
    else
      { title: nil, body: text }
    end
  end

  def faq_answer_html(answer)
    sanitize(answer.to_s, tags: %w[strong em b i br p u], attributes: [])
  end

  # In-app context help: hover or focus within the wrapper to see the tip (see .context-field-tip in app.css).
  def context_field_tip(tip_key, &block)
    tip = I18n.t("context_help.#{tip_key}")
    content_tag(:div, class: "context-field-tip", data: { tip: tip }, &block)
  end
end
