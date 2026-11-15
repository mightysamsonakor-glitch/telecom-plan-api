class Plan < ApplicationRecord
  belongs_to :customer
  belongs_to :contract_term
  has_many :plan_items, dependent: :destroy
  has_many :component_options, through: :plan_items

  enum :status, { draft: "draft", active: "active", cancelled: "cancelled" }, default: :draft

  validates :name, presence: true

  def base_price_cents
    component_options.sum(:monthly_price_cents)
  end

  # Price after the contract discount, rounded to whole cents
  def monthly_price_cents
    (base_price_cents * (100 - contract_term.discount_percent) / 100.0).round
  end

  def activate!
    update!(status: :active, activated_at: Time.current)
  end
end
