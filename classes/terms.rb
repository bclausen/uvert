#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Term
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :start_date, String
	property :end_date, String
	property :is_active, Boolean

	has n, :workloads
	has n, :teacherActives
	has n, :teachers, :through => :teacherActives
end

