class OptionsController < ApplicationController
  def index
    components = Component.includes(:component_options).order(:id).map do |component|
      options = component.component_options.select(&:active?).sort_by(&:monthly_price_cents)
      {
        code: component.code,
        name: component.name,
        unit: component.unit,
        options: options.map { |option| option_json(option) }
      }
    end

    render json: components
  end

  private

  def option_json(option)
    { id: option.id, label: option.label, monthly_price_cents: option.monthly_price_cents }
  end
end
