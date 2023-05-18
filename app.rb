require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative 'lib/listing_repository'
require_relative 'lib/booking_repository'
require_relative 'lib/user_repository'
require_relative 'lib/database_connection'

DatabaseConnection.connect('bnb_database_test')

class Application < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb :index, layout: nil
  end
  
  get '/listings' do
    repo = ListingRepository.new
    @listings = repo.all
    @current_id = session[:user_id]
    
    return erb(:listings)
  end

  get '/listings/new' do
    @current_id = session[:user_id]
    return erb(:new_listing)
  end

  get '/listings/:id' do
    repo = ListingRepository.new
    @listing = repo.find(params[:id])

    listing_start_date = @listing.start_date
    today = Time.now.to_date.to_s

    if listing_start_date < today
      @first_available_day = today
    else
      @first_available_day = listing_start_date
    end
    
    return erb(:listing)
  end

  post '/listings/:id/booking' do

    repo = BookingRepository.new
    # checks the existing bookings and if a confirmed booking is found on the same date, it fails to book and flashes a message.
    existing_bookings = repo.find_by_listing(params[:id])
    
    existing_bookings.each do |booking|
      if booking.date == params[:date] &&  booking.confirmed == true
        flash[:error] = "That date is already booked. Please select another"
        redirect "/listings/#{params[:id]}"
      end
    end

    @new_booking = Booking.new
    @new_booking.date = params[:date]
    @new_booking.confirmed = false
    @new_booking.listing_id = params[:id]
    @new_booking.user_id = session[:user_id]
       
    repo.create(@new_booking)

    return ('') 
  end

  post '/listings/new' do
       
    repo = ListingRepository.new
    new_listing = Listing.new
  
    new_listing.name = params[:name]
    new_listing.price = params[:price]
    new_listing.description = params[:description]
    new_listing.start_date = params[:start_date]
    new_listing.end_date = params[:end_date]
    new_listing.user_id = session[:user_id]
   
    
    if dates_checker(new_listing)
      status 400
      return "The end date must be after the start date. <button onclick='history.back();'>Try again.</button>"
    end

    repo.create(new_listing)
    status 200
    return 'Listing added successfully. <a href="/listings">Back to all listings</a>'
  end

  private

  def dates_checker(new_listing)
    start_date_parts = new_listing.start_date.split('-')
    start_date_to_check = Time.new(*start_date_parts)
    
    end_date_parts = new_listing.end_date.split('-')
    end_date_to_check = Time.new(*end_date_parts)

    if start_date_to_check > end_date_to_check
      return true
    end
  end

  post '/signup' do
    listing_repo = ListingRepository.new
    @listings = listing_repo.all
    
    user = User.new
    user.email = params[:email]
    user.password = params[:password]
    
    repo = UserRepository.new
    repo.create(user)
    if user.email.empty? || user.password.empty?
      status 400
      return erb(:signup_fail)
    else
      return erb(:index)
    end
  end

  post '/login' do
    listing_repo = ListingRepository.new
    @listings = listing_repo.all

    email = params[:email]
    password = params[:password]

    repo = UserRepository.new
    user = repo.find_by_email(email)
  
    sign_in_status = repo.password_correct?(user.password, password)

    if sign_in_status == true

      session[:user_id] = user.id
      @current_id = session[:user_id]
      return erb(:listings)
    else
      return erb(:signup_fail)
    end
  end

  post '/logout' do
    session.clear
    redirect '/'
  end
end