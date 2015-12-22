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

put "/attribution" do
	params.each do |entry|
	  @seperated = entry[0].partition('_')
	  @profileassignment_id = @seperated[0].to_s
	  @subject_id = @seperated[2].to_s
	  @teacher_id = entry[1].to_s
	  if @teacher_id != "" then
	  	
	  	attr = Attribution.first(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id)
		if attr.nil?
			attr = Attribution.create(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id, :teacher_id => @teacher_id)
		else
			attr = Attribution.update(:teacher_id => @teacher_id)
		end
				  	
	  end	  	
	end
	redirect ("/")
end

get "/subjects" do
	@subjects = Subject.all
	erb:subjects
end

get "/schoolclasses" do
	erb:schoolclasses
end

get "/profiles" do
	@profiles = Profile.all
	erb:profiles
end

get "/profile/:id/edit" do
	@profile = Profile.get(params[:id])
	@subjects = Subject.all
	@schoolclasses = Schoolclass.all
	erb:profile_edit
end

def get_schoolclass_teacher_options(subject_id, schoolclass_id)
	@subjects = Subject.first(:id => subject_id)
	@subjectTeacherShortcut="<option value=''>n.a.</option>"
	if Attribution.first(:subject_id => subject_id, :profileassignment_id => Profileassignment.first(:schoolclass_id=>schoolclass_id).id) != nil then	
		@assigned_teacher_id=Attribution.first(:subject_id => subject_id, :profileassignment_id => Profileassignment.first(:schoolclass_id=>schoolclass_id).id).teacher_id
	else
		@assigned_teacher_id=nil
	end
 	@subject_teachers=Department.all(:subject_id => @subjects["id"])
 	@subject_teachers.each do |teacher|
 		if @assigned_teacher_id==nil or @assigned_teacher_id!=teacher.teacher_id then
 			@subjectTeacherShortcut = @subjectTeacherShortcut + "<option value=" + (teacher.teacher_id).to_s+ ">" + Teacher.first(id: teacher.teacher_id).shortcut.to_s + "</option>"
 		else
 			@subjectTeacherShortcut = @subjectTeacherShortcut + "<option value=" + (teacher.teacher_id).to_s+ " selected>" + Teacher.first(id: teacher.teacher_id).shortcut.to_s + "</option>"
 		end
 	end
	return @subjectTeacherShortcut
end

def is_active?(link_path)
	if request.path_info.include? link_path.to_s then
		return "active" 
	else 
		return ""
 	end
end

def prepare_attrib_table
	@options=[]
	@attrib_table=[]
	@schoolclasses = Schoolclass.all
	@subjects = Subject.all
			@subjects.each do |subject|
				zeile = "<tr> <td>" + subject.name + "</td>"
				@subject_teachers=Department.all(:subject_id => subject.id)
				@schoolclasses.each do |schoolclass|
					
					zeile = zeile + "<td>"
					if Profileassignment.first(schoolclass_id: schoolclass.id) != nil then 
						@profileassignment_id = Profileassignment.first(schoolclass_id: schoolclass.id).id
						@options[subject.id]=get_schoolclass_teacher_options(subject.id,schoolclass.id)
						@profil_id=Profileassignment.first(schoolclass_id: schoolclass.id).profile_id 
						profilsub = Profilesubject.first(:profile_id => @profil_id, :subject_id => subject.id)
						if profilsub != nil then
							zeile= zeile + "<select name=" + @profileassignment_id.to_s + "_" + subject.id.to_s + ">" +	@options[subject.id] + "</select>" + profilsub.hours.to_s 
						end
					end
					zeile = zeile + "</td> "
				end
				zeile = zeile + "</tr> "
				@attrib_table.push(zeile)
			end
	return @attrib_table
end