module ApplicationHelper
     INLINE_HTML_TAGS = %i[a abbr b bdi bdo br button cite code data del dfn em i img input ins kbd label mark q ruby s samp select small span strong sub sup textarea time u var].freeze
     private_constant :INLINE_HTML_TAGS

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

     def context_field_tip(tip_key, &block)
          tip = I18n.t("context_help.#{tip_key}", default: "")
          content_tag(:div, class: "context-field-tip", data: { tip: tip }, &block)
     end

     def sponsor_logo_or_name(
       sponsor,
       image_class:,
       fallback_class:,
       fallback_tag: :div,
       show_fallback_when_logo_missing: true,
       show_fallback_on_logo_error: true
     )
          if sponsor.logo_url.present?
               image_options = {
                 alt: sponsor.name,
                 class: image_class,
                 loading: "lazy"
               }

               if show_fallback_on_logo_error
                    image = image_tag(
                      sponsor.logo_url,
                      **image_options.merge(data: { sponsor_logo_target: "image", action: "error->sponsor-logo#handleError" })
                    )
                    fallback = content_tag(
                      fallback_tag,
                      sponsor.name,
                      class: "hidden #{fallback_class}",
                      data: { sponsor_logo_target: "fallback" }
                    )
                    wrapper_tag = inline_html_tag?(fallback_tag) ? :span : :div
                    return content_tag(wrapper_tag, safe_join([ image, fallback ]), data: { controller: "sponsor-logo" })
               end

               return image_tag(sponsor.logo_url, **image_options)
          end

          return "".html_safe unless show_fallback_when_logo_missing

          content_tag(fallback_tag, sponsor.name, class: fallback_class)
     end

  private

       def inline_html_tag?(tag_name)
            INLINE_HTML_TAGS.include?(tag_name.to_sym)
       end
end
