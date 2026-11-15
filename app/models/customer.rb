class Customer < ApplicationRecord
  has_many :plans, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
