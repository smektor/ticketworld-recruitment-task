# frozen_string_literal: true

json.tickets do
  json.available @ticket.available
  json.reserved @ticket.reserved_count
  json.paid @ticket.paid_count
  json.price @ticket.price
end