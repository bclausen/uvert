#!/bin/env ruby
# encoding: utf-8

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../db/uvert.db")

class Department
	include DataMapper::Resource
	property :id, Serial

	belongs_to :teacher
	belongs_to :subject
	
	# def self.subject(id)
 # 	    all(:subject_id => id)
 #    end

end

