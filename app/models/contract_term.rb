class ContractTerm < ApplicationRecord
  has_many :plans, dependent: :restrict_with_error

  validates :months, presence: true, uniqueness: true,
                     numericality: { only_integer: true, greater_than: 0 }
  validates :discount_percent, numericality: { only_integer: true, in: 0..50 }
end
