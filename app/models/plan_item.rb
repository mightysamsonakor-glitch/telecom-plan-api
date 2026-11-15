class PlanItem < ApplicationRecord
  belongs_to :plan
  belongs_to :component
  belongs_to :component_option

  before_validation { self.component ||= component_option&.component }

  validates :component_id, uniqueness: { scope: :plan_id, message: "already chosen for this plan" }
  validate :option_matches_component

  private

  def option_matches_component
    return if component.nil? || component_option.nil?
    return if component_option.component_id == component_id

    errors.add(:component_option, "does not belong to #{component.code}")
  end
end
