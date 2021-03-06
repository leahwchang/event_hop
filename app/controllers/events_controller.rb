class EventsController < ApplicationController
  before_action :authenticate_user!, only:[:new, :create, :join]
  before_action :set_event, only: [:show, :join, :leave]
  before_action :set_place, only: [:create, :new]

  def new
    @event = Event.new
  end

  def index
    @posts = Post.last(10).reverse
  end

  def show
    @place = @event.place
    @post = Post.new

    # gmap
    @hash = Gmaps4rails.build_markers(@place) do |place, marker|
      marker.lat place.latitude
      marker.lng place.longitude
      marker.infowindow place.name
    end
  end

  def create
    @event = @place.events.new(event_params)
    if Time.now < @event.start
      if @event.save
        # grabbing emails from event creation form
        # passing it in as an array of individual strings
        # take out white space and split by comma
        @emails = params[:event][:email].gsub(" ", "").split(",")
        @emails.each do |email|
          EventMailer.invitation(current_user, email, @event).deliver_now
        end
        redirect_to user_path(current_user.id), notice: "Event Saved!"
      else
        redirect_to :back, notice: "There was a Problem. Please Try Again."
      end
    else

      # need to not save the event when there is a problem
      redirect_to :back, notice: "There was a Problem. Please Try Again."
    end
  end

  def join
    @event.users << current_user
    redirect_to @event, notice: "Thanks For Joining!"
  end

  def leave
   @event.users.delete(current_user)
   redirect_to @event, notice: "Sad To See You Go."
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end

  def set_place
    @place = Place.find(params[:place_id])
  end

  def event_params
    params.require(:event).permit(:start, :description, :email).merge(user: current_user)
  end

end
