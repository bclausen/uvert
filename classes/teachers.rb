#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Teacher
	include DataMapper::Resource
	property :id, Serial
	property :lastname, String
	property :firstname, String
	property :shortcut, String
	#Teste git-Push
	has n, :workloads
	has n, :departments
	has n, :subjects, :through => :departments
	has n, :teacherActives
	has n, :terms, :through => :teacherActives
	has n, :attributions
	#has n, :subjects, :through => :attributions
	has n, :profileassignments, :through => :attributions
end



