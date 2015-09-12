require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name}_id".downcase.to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || "#{name}".camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] || "#{self_class_name}_id".downcase.to_sym

    self.class_name = options[:class_name] || "#{name}".singularize.camelcase

    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, opts = {})
    options = BelongsToOptions.new(name, opts)
    assoc_options[name.to_sym] = options

    define_method "#{name}" do
      target_id = self.send("#{options.foreign_key}")
      params = { "#{options.primary_key}".to_sym => target_id }
      options.model_class.where(params).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    assoc_options[name.to_sym] = options

    define_method "#{name}" do
      target_id = self.send("#{options.primary_key}")
      params = { "#{options.foreign_key}".to_sym => target_id }
      options.model_class.where(params)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
