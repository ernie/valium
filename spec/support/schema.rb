require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

class Person < ActiveRecord::Base
  serialize :extra_info
end

class Widget < ActiveRecord::Base
  serialize :extra_info
  set_primary_key :widget_id
end

module Schema
  def self.create
    ActiveRecord::Base.silence do
      ActiveRecord::Migration.verbose = false

      ActiveRecord::Schema.define do
        create_table :people, :force => true do |t|
          t.string   :first_name
          t.string   :last_name
          t.integer  :age
          t.text     :extra_info
          t.timestamps
        end

        create_table :widgets, :force => true, :primary_key => :widget_id do |t|
          t.string   :name
          t.text     :extra_info
          t.timestamps
        end
      end
    end

    1.upto(100) do |num|
      Person.create! :first_name => "Person", :last_name => "Number#{num}", :age => num % 99,
                     :extra_info => {:a_key => "Value Number #{num}"}
    end

    1.upto(100) do |num|
      Widget.create! :name => "Widget #{num}",
                     :extra_info => {:a_key => "Value Number #{num}"}
    end

  end
end