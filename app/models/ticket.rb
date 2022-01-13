# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :event
  has_many :reservations, dependent: :destroy

  enum validation_type: [:default, :even, :avoid_one]

  validates :event, :price, :available, presence: true

  def reserved_count
    reservations.where(status: :reserved).sum(:tickets_count)
  end

  def paid_count
    reservations.where(status: :paid).sum(:tickets_count)
  end
end
