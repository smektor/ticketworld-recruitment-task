# frozen_string_literal: true

class EventsController < ApiController
  before_action :set_event, only: :show

  def index
    @events = Event.all
  end

  def available
    @events = Event.where(time: DateTime.now..)

    render :index
  end

  def show
    render :show
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound => error
    not_found_error(error)
  end
end
