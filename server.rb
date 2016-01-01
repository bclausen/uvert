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
	# Erzeuge HTML-Tabellenzellen für Fächer mit Stundenzahl des Profils
	@subjects_hour_tabledata = []
	@subjects.each do |subject|
		profile_subject = Profilesubject.first(:profile_id =>@profile.id, :subject_id => subject.id)
		if profile_subject.nil? then
			tabledata = "<td><font color='#CCCCCC'>" + subject.name + "</font></td>"
		else
			tabledata = "<td>" + subject.name + "</td>"
		end
		tabledata = tabledata + "<td>"
		name_subject_hour_field = subject.id.to_s + "_hours"
		if profile_subject.nil? then
			hours = '0'
		else
			hours = profile_subject.hours
		end
		tabledata = tabledata + "<input type='text' name=' " + name_subject_hour_field + "' value =" + hours.to_s + ">"
		tabledata = tabledata + "</td>"
		@subjects_hour_tabledata.push(tabledata)
	end
	###############################
	# Erzeuge HTML-Tabellenzellen für die Zuordnung von Klassen geordnet nach Jahrgängen
	@grades = Grade.all
	@schoolclasses_tabledata = []
	@grades.each do |grade|
		tabledata = "<td>"
		schoolclasses = Schoolclass.all(:grade_id => grade.id)
		schoolclasses.each do |schoolclass|
			profileassignment = Profileassignment.first(:profile_id.like => @profile.id, :schoolclass_id => schoolclass.id)
			name_class_field = schoolclass.id
			if profileassignment.nil? then
				tabledata = tabledata + "<font color='#CCCCCC'>" + schoolclass.name + "</font>" + "&nbsp"
				checked = ''
			else
				tabledata = tabledata +  schoolclass.name + "&nbsp"
				checked = 'checked' 
			end
			tabledata = tabledata + "<input type='checkbox' name='" + name_class_field.to_s + "'" + checked + ">" + "&nbsp"
		end
		tabledata = tabledata + "</td>"
		@schoolclasses_tabledata.push(tabledata)
	end
	###############################
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

get '/subject/:id/teachers' do
    get_suggested_teachers_for(params[:id].to_i).to_s
end


helpers do

	def get_suggested_teachers_for(subject_id) #Hier wird bisher nur eine Liste der Fachlehrer zurückgegeben. Langfristig sollen es Empfehlungen aufgrund der Unterstunden sein.
		@subject_teachers=Department.all(:subject_id => subject_id)
		result="Unterstunden: "
		@subject_teachers.each do |teacher|	
			result= result+ Teacher.first(:id => teacher.teacher_id).shortcut.to_s + ", "
		end
		result=result[0...-2] + " &Uuml;berstunden: "
		@subject_teachers.each do |teacher|	
			result= result+ Teacher.first(:id => teacher.teacher_id).shortcut.to_s + ", "
		end
		return result[0...-2]
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
					zeile = "<tr> <td><a href='/subject/"+subject.id.to_s+"' title='"+get_suggested_teachers_for(subject.id)+"' class='masterTooltip'>" + subject.name + "</a></td>"
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
			index = @@attrib_table[i].index(' name='+profileassignment_id.to_s+'_'+subject_id.to_s + ' ')
			if  index != nil then
				index_start= @@attrib_table[i].rindex('<select', index)
				index_end= @@attrib_table[i].index('</select>', index)+8
				if @@attrib_table[i][index_start..index_end].sub!('selected','') != nil then
					without_selected=@@attrib_table[i][index_start..index_end].sub!('selected','')
				else
					without_selected=@@attrib_table[i][index_start..index_end]
				end
				selected_teacher_index=without_selected.index('value='+teacher_id.to_s)
				with_selected_teacher=without_selected.insert(selected_teacher_index+('value='+teacher_id.to_s).size, ' selected')
				@@attrib_table[i].sub!(@@attrib_table[i][index_start..index_end], with_selected_teacher)
				altered=true
			end
			i=i+1
		end 
	end
end