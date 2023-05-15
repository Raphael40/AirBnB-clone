require 'database_connection'
require 'user'

class UserRepository
  def all
    sql = 'SELECT id, email, password FROM users;'
    result_set = DatabaseConnection.exec_params(sql, [])
    users = []
    result_set.each do |record|
      user = User.new
      user.id = record['id'].to_i
      user.email = record['email']
      user.password = record['password']
      users << user
    end
    return users
  end
  
  def create(user)
    sql = 'INSERT INTO users(email, password) VALUES ($1, $2);'
    params = [user.email, user.password]
    result_set = DatabaseConnection.exec_params(sql, params)
  end
end