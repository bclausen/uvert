#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Grade
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :is_levelII, Boolean
end

