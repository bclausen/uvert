#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Teacher_active
	include DataMapper::Resource
	property :id, Serial
	property :teacher_id, Integer
	property :term_id, Integer
end

DataMapper.finalize