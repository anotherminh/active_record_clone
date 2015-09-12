require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options
  # class Cat < SQLObject
  #
  # belongs_to :human, :foreign_key => :owner_id
  # has_one_through :home, :human, :house

  # class Human < SQLObject
  # self.table_name = "humans"
  #
  # belongs_to :house
  #cat belongs_to :home, :through => :human, :source => :home
  # SELECT
  #   houses.*
  # FROM
  #   humans
  # JOIN
  #   houses ON humans.house_id = houses.id
  # WHERE
  #   humans.id = ?

  def has_one_through(name, through_name, source_name)

    define_method "#{name}" do
      through_opts = self.class.assoc_options[through_name]
      source_opts = through_opts.model_class.assoc_options[source_name]

      source_table = source_opts.model_class.table_name
      through_table = through_opts.model_class.table_name
      target_id = self.send("#{through_opts.foreign_key}")

      result = DBConnection.execute(<<-SQL, target_id).first
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_table}.#{source_opts.foreign_key}  = #{source_table}.#{source_opts.primary_key}
        WHERE
          #{through_table}.id = ?
      SQL

      source_opts.model_class.new(result)
    end

  end
end
