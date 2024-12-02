require 'sqlite3'

class ReportAnalyzer
  def initialize(db_path = 'reports.db')
    @db = SQLite3::Database.new(db_path)
    setup_database
  end

  def setup_database
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS reports (
        id INTEGER PRIMARY KEY,
        levels TEXT,
        is_safe BOOLEAN
      );
    SQL
  end

  def safe?(levels)
    return false if levels.length < 2
    
    differences = levels.each_cons(2).map { |a, b| b - a }
    
    # Check if differences are all positive (increasing) or all negative (decreasing)
    all_increasing = differences.all? { |d| d > 0 }
    all_decreasing = differences.all? { |d| d < 0 }
    
    # Check if differences are within allowed range (1 to 3)
    valid_differences = differences.all? { |d| d.abs >= 1 && d.abs <= 3 }
    
    (all_increasing || all_decreasing) && valid_differences
  end

  def process_input(input)
    reports = input.strip.split("\n")
    reports.each do |report|
      levels = report.strip.split.map(&:to_i)
      is_safe = safe?(levels)
      @db.execute("INSERT INTO reports (levels, is_safe) VALUES (?, ?)", 
                 [levels.join(' '), is_safe ? 1 : 0])
    end
  end

  def count_safe_reports
    @db.get_first_value("SELECT COUNT(*) FROM reports WHERE is_safe = 1")
  end

  def display_results
    puts "\nAnalysis Results:"
    puts "-----------------"
    @db.execute("SELECT levels, is_safe FROM reports") do |report|
      levels = report[0]
      is_safe = report[1] == 1
      status = is_safe ? "SAFE" : "UNSAFE"
      puts "#{levels}: #{status}"
    end
    puts "\nTotal safe reports: #{count_safe_reports}"
  end
end

if __FILE__ == $0
  # Try to read from test_input.txt if it exists
  input = if File.exist?('02input.txt')
    File.read('02input.txt')
  else
    puts "Please enter your reports (one per line, empty line to finish):"
    input = []
    while (line = gets.chomp) != ""
      input << line
    end
    input.join("\n")
  end

  analyzer = ReportAnalyzer.new
  analyzer.process_input(input)
  analyzer.display_results
end
