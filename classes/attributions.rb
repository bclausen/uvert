#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Attribution
	include DataMapper::Resource
	property :id, Serial
	
	belongs_to :teacher
	belongs_to :subject
	belongs_to :profileassignment
end

