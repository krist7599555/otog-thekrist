# frozen_string_literal: true

class BulmaFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  def text_field(method, options = {})
    options[:class] = "#{options[:class]} input".strip
    options[:id] = method
    content_tag(:div, class: "field") do
      content_tag(:label, method.to_s.humanize, class: "label", for: method) +
        content_tag(:div, class: "control") do
          super(method, options)
        end
    end
  end

  def text_area(method, options = {})
    options[:class] = "#{options[:class]} textarea".strip
    options[:id] = method
    content_tag(:div, class: "field") do
      content_tag(:label, method.to_s.humanize, class: "label", for: method) +
        content_tag(:div, class: "control") do
          super(method, options)
        end
    end
  end

  def submit(value = nil, options = {})
    options[:class] = "#{options[:class]} button is-primary".strip
    super
  end

  def label
    content_tag(:label, class: "label") do
      super(method, options)
    end
  end

  def field
    content_tag(:div, class: "field") do
      super(method, options)
    end
  end

  # Add similar overrides for other form helpers like text_area, select, etc.
end
