class ComponentOption < ApplicationRecord
  belongs_to :component

  scope :available, -> { where(active: true) }

  validates :monthly_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount, numericality: { only_integer: true, greater_than: 0 }, unless: :unlimited?
  validates :amount, absence: true, if: :unlimited?

  def label
    unlimited? ? "unlimited #{component.unit}" : "#{amount} #{component.unit}"
  end
end
