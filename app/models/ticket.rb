# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :event
  has_many :reservations, dependent: :destroy

  def reserved_count
    reservations.where(status: :reserved).sum(:tickets_count)
  end

  def paid_count
    reservations.where(status: :paid).sum(:tickets_count)
  end
end
