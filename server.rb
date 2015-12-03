require "sinatra"
require 'sinatra/reloader' if development?

require './classes/attributions'
require './classes/compensations'
require './classes/departments'
require './classes/grades'
require './classes/profileassignments'
require './classes/profiles'
require './classes/profilesubjects'
require './classes/schoolclasses'
require './classes/subjects'
require './classes/teacherActives'
require './classes/teachers'
require './classes/terms'
require './classes/workloads'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/uvert.db")
DataMapper.finalize

get "/" do
	erb:home
end

get "/teachers" do
	@teachers = Teacher.all
	erb:teachers
end

get "/teacher/:id" do
	@teacher = Teacher.get(params[:id])
	erb:show_teacher
end

get "/attributions" do
	@attributions = Attribution.all
	erb:attributions
end

get "/subjects" do
	@subjects = Subject.all
	erb:subjects
end

get "/schoolclasses" do
	erb:schoolclasses
end