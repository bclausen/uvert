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
	@schoolclasses = Schoolclass.all
	erb:attributions
end

post "/attribution" do
	@profileassignment_id = params[:profileassignment_id] 
 	@subject_id = params[:subject_id]  
 	@teacher_id = params[:teacher_id] 
  	attr = Attribution.first(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id)
	if @teacher_id != "" then
	  	
	  	if attr.nil?
			attr = Attribution.create(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id, :teacher_id => @teacher_id)
		else
			attr.update(:teacher_id => @teacher_id)
		end

	else

		if not attr.nil?
			attr.destroy
			alter_attrib_table(@profileassignment_id, @subject_id,'')
		end
				  	
	end
	alter_attrib_table(@profileassignment_id, @subject_id, @teacher_id)
end

put "/attribution" do
	
	params.each do |entry|
	  @seperated = entry[0].partition('_')
	  @profileassignment_id = @seperated[0].to_s
	  @subject_id = @seperated[2].to_s
	  @teacher_id = entry[1].to_s
	  
	  attr = Attribution.first(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id)
	  if @teacher_id != "" then
	  	
		  	if attr.nil?
				attr = Attribution.create(:subject_id => @subject_id, :profileassignment_id => @profileassignment_id, :teacher_id => @teacher_id)
			else
				attr.update(:teacher_id => @teacher_id)
			end

		else

			if not attr.nil?
				attr.destroy
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

put '/profile/:id' do
  #Testausgabe der benannten Parameter
  #params[:profile]# + params[:hours].to_s
  profile = Profile.get(params[:id])
  #Im folgenden wird das Profil aktualisiert (nur der Name)
  profile.update(params[:profile])
  #Das Aktualisieren der profilassignments und der profilesubjects wird nicht
  #so einfach, da die datensätze nicht einfach geändert werden müssen, sondern
  #erst erzeugt bzw. gelöscht werden müssen
  parameter = params.select {|key, val| not val.empty?}.values
  #parameter.to_s #Herüber erfolgt keine Ausgabe im Browser 
   "Hallo" + params.to_s
 # "Hallo" + params[0][0]
  #redirect ("/profiles")
end

helpers do

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
								zeile= zeile + "<select name=" + @profileassignment_id.to_s + "_" + subject.id.to_s + " onchange='getval(this);'>" +	@options[subject.id] + "</select>" + profilsub.hours.to_s 
							end
						end
						zeile = zeile + "</td> "
					end
					zeile = zeile + "</tr> "
					@attrib_table.push(zeile)
				end
		return @attrib_table
	end

	def alter_attrib_table(profileassignment_id, subject_id, teacher_id)
		i=0 
		altered = false
		while i < @@attrib_table.size and not altered do
			#alter
			index = @@attrib_table[i].index(' name='+profileassignment_id.to_s+'_'+subject_id.to_s + ' ')
			#puts(index)
			if  index != nil then
				index_start= @@attrib_table[i].rindex('<select', index)
				#puts(index_start)
				index_end= @@attrib_table[i].index('</select>', index)+8
				#puts(index_end)
				if @@attrib_table[i][index_start..index_end].sub!('selected','') != nil then
					without_selected=@@attrib_table[i][index_start..index_end].sub!('selected','')
				else
					without_selected=@@attrib_table[i][index_start..index_end]
				end
				puts(without_selected)
				selected_teacher_index=without_selected.index('value='+teacher_id.to_s)
				puts(selected_teacher_index)
				puts(('value='+teacher_id.to_s).size)
				with_selected_teacher=without_selected.insert(selected_teacher_index+('value='+teacher_id.to_s).size, ' selected')
				puts(with_selected_teacher)
				@@attrib_table[i].sub!(@@attrib_table[i][index_start..index_end], with_selected_teacher)
				altered=true
			end
			i=i+1
		end 

		
	end
end