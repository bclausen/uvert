#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Compensation
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :hours, Float
	property :teacher_id, Integer
	property :term_id, Integer
end

