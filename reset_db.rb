require 'sqlite3'

def reset_database
  # Remove existing database file if it exists
  File.delete('reports.db') if File.exist?('reports.db')
  
  # Create a new database
  db = SQLite3::Database.new('reports.db')
  
  # Create the reports table
  db.execute <<-SQL
    CREATE TABLE reports (
      id INTEGER PRIMARY KEY,
      levels TEXT,
      is_safe BOOLEAN
    );
  SQL
  
  puts "Database has been reset successfully."
rescue SQLite3::Exception => e
  puts "Error occurred while resetting database: #{e}"
ensure
  db&.close
end

reset_database
