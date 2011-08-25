require 'active_record'

module ActiveRecord
  class SQLCounter
    IGNORED_SQL = [/^PRAGMA /, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/,
      /SELECT name\s+FROM sqlite_master\s+WHERE type = 'table' AND NOT name = 'sqlite_sequence'/]

    # FIXME: this needs to be refactored so specific database can add their own
    # ignored SQL.  This ignored SQL is for Oracle.
    IGNORED_SQL.concat [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from all_triggers/im]

    def initialize
      $queries_executed = []
    end

    def call(name, start, finish, message_id, values)
      sql = values[:sql]

      unless 'CACHE' == values[:name]
        $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
      end
    end
  end
  ActiveSupport::Notifications.subscribe('sql.active_record', SQLCounter.new)
end

Dir[File.expand_path('../{helpers,support}/*.rb', __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.before(:suite) do
    puts '=' * 80
    puts "Running specs against ActiveRecord #{ActiveRecord::VERSION::STRING}..."
    puts '=' * 80
    Schema.create
  end

  config.include ValiumHelper
end

require 'valium'