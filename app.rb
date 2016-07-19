require 'sinatra'
require "sinatra/activerecord"

class Doctor < ActiveRecord::Base
  validates_presence_of :name
end

class QueryPagination < Struct.new(:base_relation, :options)
  FIELD = 'id'
  MAX_SIZE = 200

  def records
    base_records.limit(max)
  end

  def page_header
    {
      field: field,
      start: records.first.try(field),
      end: records.last.try(field),
    }
  end
 
   def next_page_header
    return nil unless next_page?
    {
      field: field,
      start: records.last.try(field),
      max: max
    }
  end

  def next_page?
    base_records.size > max
  end

  private 

  def field 
    options['field'] || FIELD
  end

  def order 
    options['order'] || 'ASC'
  end

  def max
    if options['max'] && options['max'].to_i < MAX_SIZE
      options['max'].to_i
    else
      MAX_SIZE
    end
  end

  def table_name
    base_relation.table_name
  end

  def base_records
    base_records = base_relation.reorder("#{table_name}.#{field} #{order}")
    base_records = base_records.
      where("#{table_name}.#{field} >= ?", options['start']) if options['start']
    base_records = base_records.
      where("#{table_name}.#{field} <= ?", options['end']) if options['end']
    base_records
  end
end

get '/doctors' do 
  range_header = JSON.parse(env["HTTP_RANGE"] || '{}')
  result = QueryPagination.new(Doctor, range_header )
  content_type :json
  headers['Content-Range'] = result.page_header.to_json
  headers['Next-Range'] = result.next_page_header.to_json if result.next_page?
  { :doctors => result.records.map(&:to_json) }.to_json
end

