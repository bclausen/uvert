#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Profileassignment
	include DataMapper::Resource
	property :id, Serial
	#property :profile_id, Integer
	#property :schoolclass_id, Integer

	has n, :attributions
	has n, :subjects, :through => :attributions
	has n, :teachers, :through => :attributions

	belongs_to :profile
	belongs_to :schoolclass
end

