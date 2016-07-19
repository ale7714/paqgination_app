require 'sinatra'
require "sinatra/activerecord"

class Doctor < ActiveRecord::Base
  validates_presence_of :name
end


get '/doctors' do 

end