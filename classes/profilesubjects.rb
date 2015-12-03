#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Profilesubject
	include DataMapper::Resource
	property :id, Serial
	property :profile_id, Integer
	property :subject_id, Integer
	property :hours, Integer
end

