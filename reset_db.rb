require 'sqlite3'

def reset_database
  # Connect to the existing database or create a new one if it doesn't exist
  db = SQLite3::Database.new('reports.db')

  # Drop the existing reports table if it exists
  db.execute("DROP TABLE IF EXISTS reports")
  
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
