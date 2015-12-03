#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Profile
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :term_id, Integer
	
	has n, :profileassignments
	has n, :schoolclasses, :through => :profileassignments
end

