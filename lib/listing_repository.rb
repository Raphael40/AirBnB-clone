require_relative 'listing'

class ListingRepository

  def all
    sql = 'SELECT id, name, price, description, start_date, end_date, user_id FROM listings;'
    result_set = DatabaseConnection.exec_params(sql, [])

    listings = []

    result_set.each do |record|
      listing = Listing.new
      listing.id = record['id']
      listing.name = record['name']
      listing.price = record['price']
      listing.description = record['description']
      listing.start_date = record['start_date']
      listing.end_date = record['end_date']
      listing.user_id = record['user_id']

      listings << listing
    end
    return listings

  end

  def create(listing)
    sql = 'INSERT INTO listings (name, price, description, start_date, end_date, user_id) VALUES ($1, $2, $3, $4, $5, $6);'
    params = [listing.name, listing.price, listing.description, listing.start_date, listing.end_date, listing.user_id]
    DatabaseConnection.exec_params(sql, params)
  end

  def find_by_user_id(user_id)
    sql = 'SELECT id, name, price, description, start_date, end_date, user_id FROM listings WHERE user_id = $1;'
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql, sql_params)

    listings = []
    
    result_set.each do |record|
      listing = Listing.new
      listing.id = record['id']
      listing.name = record['name']
      listing.price = record['price']
      listing.description = record['description']
      listing.start_date = record['start_date']
      listing.end_date = record['end_date']
      listing.user_id = record['user_id']

      listings << listing
    end
    return listings
  end

  def find(id)
    sql = "SELECT id, name, price, description, start_date, end_date, user_id FROM listings WHERE id = $1;"
    sql_params = [id]
    result_set = DatabaseConnection.exec_params(sql, sql_params)
    listing = Listing.new
    listing.id = result_set[0]['id']
    listing.name = result_set[0]['name']
    listing.price = result_set[0]['price']
    listing.description = result_set[0]['description']
    listing.start_date = result_set[0]['start_date']
    listing.end_date = result_set[0]['end_date']
    listing.user_id = result_set[0]['user_id']

    return listing
  end
end