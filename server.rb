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
	#prepare_attrib_table
	@@attrib_table=prepare_attrib_table
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
	#@attributions = Attribution.all
	@anfang = Time.now
	@schoolclasses = Schoolclass.all
	#prepare_attrib_table
	erb:attributions
end

get "/attributions2" do
	# @subject_array =[]
	# @subjects = Subject.all
	# @subjects.each do |subject|
	# 	@subject_array.push(subject.name)
	# 	@subject_array.push(subject.id) 
	# end
	#2. Idee: Schon fertigen HTML-Code generieren
	@attribution_html ="<table> "
	@schoolclasses = Schoolclass.all
	#Hinzufürgen der Klassennamen als Überschrift
	@schoolclasses.each do |schoolclass|
		@attribution_html = @attribution_html + " <th> " + schoolclass.name + "</th>"
	end
	#Hinzufügen der Fächer
	@subjects = Subject.all
	@subjects.each do |subject|
		@attribution_html = @attribution_html + "<tr> <td>" + subject.name + "<td>"
		@schoolclasses.each do |schoolclass|
			@subject_teachers=Department.all(:subject_id => subject.id)
			@attribution_html = @attribution_html + "<td> <select name='" + (schoolclass.id).to_s + "_" +(subject.id).to_s + "' >"
			#Ab hier verzögert sich das laden der Seite
			# @subject_teachers.each do |teacher|
			# 	@attribution_html = @attribution_html + "<option value='"+ (teacher.teacher_id).to_s + "'>" + Teacher.first(id: teacher.teacher_id).shortcut + "</option>"
			# end
			# @attribution_html = @attribution_html + "</select>"
			#Hinzufügen der Stündigkeit (dies hat auch ein bisschen Einfluss auf die Ladegeschwindigeit)
			# if Profileassignment.first(schoolclass_id: schoolclass.id) != nil then
			# 	@profil_id=Profileassignment.first(schoolclass_id: schoolclass.id).profile_id
			# 	Profilesubject.all(:profile_id => @profil_id, :subject_id => subject.id).each do |profile_subject|
			# 		@attribution_html = @attribution_html + profile_subject.hours.to_s
			# 	end
			# end
			@attribution_html = @attribution_html + "</td>"
		end
		@attribution_html = @attribution_html + "</tr>"
	end

	@attribution_html = @attribution_html + " </table>"
	erb:attributions2
end

get "/subjects" do
	@subjects = Subject.all
	erb:subjects
end

get "/schoolclasses" do
	erb:schoolclasses
end


def get_subject_teacher_options(id)
	@subjects = Subject.all(:id => id)
	@subjectTeacherShortcut=""
	@subjects.each do |subject|
	 	@subject_teachers=Department.all(:subject_id => subject.id)
	 	@subject_teachers.each do |teacher|
	 		@subjectTeacherShortcut = @subjectTeacherShortcut + "<option value=" + (teacher.teacher_id).to_s+ ">" + Teacher.first(id: teacher.teacher_id).shortcut.to_s + "</option>"
	 	end
	end
	return @subjectTeacherShortcut
end

def prepare_attrib_table
	####DIESER TEIL IST NOTWENDIG FÜR DIE DARSTELLUNG DER VERTEILUNG
    @subjects = Subject.all
	@options=[]	
		@subjects.each do |subject|
			@options[subject.id]=get_subject_teacher_options(subject.id)
		end
	####DIE OBIGE AUSLAGERUNG BRINGT AUF MEINEM ALTEN THINKPAD 0,2 SEKUNDEN
	@attrib_table=[]
	@schoolclasses = Schoolclass.all
	@subjects = Subject.all
			@subjects.each do |subject|
				zeile = "<tr> <td>" + subject.name + "</td>"
				@subject_teachers=Department.all(:subject_id => subject.id)
				@schoolclasses.each do |schoolclass|
					zeile = zeile + "<td>"
					if Profileassignment.first(schoolclass_id: schoolclass.id) != nil then 
						@profil_id=Profileassignment.first(schoolclass_id: schoolclass.id).profile_id 
						profilsub = Profilesubject.first(:profile_id => @profil_id, :subject_id => subject.id)
						if profilsub != nil then
							zeile= zeile + "<select name=" + schoolclass.id.to_s + "_" + subject.id.to_s + ">" +	@options[subject.id] + "</select>" + profilsub.hours.to_s 
						end
					end
					zeile = zeile + "</td> "
				end
				zeile = zeile + "</tr> "
				@attrib_table.push(zeile)
			end
	return @attrib_table
end