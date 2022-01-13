# frozen_string_literal: true

class Event < ApplicationRecord
  has_one :ticket, dependent: :destroy

  validates :name, :time, presence: true

  def formatted_time
    time.strftime("%d %B %Y, %H:%M")
  end
end
