class Component < ApplicationRecord
  has_many :component_options, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, :unit, presence: true
end
