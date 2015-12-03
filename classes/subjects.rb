#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Subject
	include DataMapper::Resource
	
	property :id, Serial
	property :name, String
	property :shortcut, String

	has n, :departments
	has n, :teachers, :through => :departments

	has n, :attributions
	has n, :teachers, :through => :attributions
	has n, :profileassignments, :through => :attributions
end

