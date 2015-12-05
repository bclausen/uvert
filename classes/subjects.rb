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

	

	has n, :attributions
	has n, :teachers, :through => :attributions
	has n, :profileassignments, :through => :attributions

	has n, :departments
	has n, :teachers, :through => :departments

	def self.teachers
		Department.all(:subject_id => self.id)
	end
end

