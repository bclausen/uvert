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
require './helpers/teacher_functions'

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
	@active_term = get_active_term
	@teacher_overtime = get_teacher_overtime(@teacher.id)
	erb:teacher_show
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
	@schoolclasses = Schoolclass.all
	@sc_id_without_profile = []
	@schoolclasses.each do |schoolclass|
		if Profileassignment.first(:schoolclass_id => schoolclass.id).nil? then
			@sc_id_without_profile.push(schoolclass)
		end
	end
	erb:profiles
end

get "/profiles/new" do
	erb:profile_new
end

post "/profiles" do
	active_term = get_active_term
	profile = Profile.create(name: params[:profile_name], term_id: active_term.id)
	redirect to("/profile/#{profile.id}/edit")
end

delete "/profiles/:id/delete" do
	#Profil wird gelöscht
	profile = Profile.first(:id => params[:id])
	profile.destroy
	#Profilassignments werden gelöscht
	#Profilesubjects werden gelöscht
	redirect to("/profiles")
end

post "/profile/name/update" do
	@profile_id = params[:profile_id] 
 	@profile_name = params[:profile_name]  
 	profile = Profile.get(@profile_id)
  	#Im folgenden wird das Profil aktualisiert (nur der Name)
  	profile.update(:name => @profile_name)
end

post "/profile/subject_hour/update" do
	profile_id = params[:profile_id].to_i 
	subject_id = params[:subject_id].to_i
	subject_hour = params[:subject_hour].to_i
	profilesubject = Profilesubject.first(:profile_id => profile_id, :subject_id => subject_id)

	if profilesubject.nil? then
		Profilesubject.create(:profile_id => profile_id, :subject_id => subject_id, :hours => subject_hour)
	else
		if subject_hour != 0 then
			profilesubject.update(:hours => subject_hour)
		else
			profilesubject.destroy
		end
	end
end

post "/profile/class/update" do
	@profile_id = params[:profile_id]
	@class_id = params[:class_id]
	profileassignment = Profileassignment.first(:profile_id => @profile_id, :schoolclass_id => @class_id)
	if profileassignment.nil? then
		Profileassignment.create(:profile_id => @profile_id, :schoolclass_id => @class_id)
	else
		profileassignment.destroy
	end
end

get "/profile/:id/edit" do
	@profile = Profile.get(params[:id])
	@subjects = Subject.all
	# Erzeuge HTML-Tabellenzellen für Fächer mit Stundenzahl des Profils
	@subjects_hour_tabledata = get_profile_subjects_hour_tabledata(@profile.id)
	# Erzeuge HTML-Tabellenzellen für die Zuordnung von Klassen geordnet nach Jahrgängen
	@@schoolclasses_tabledata = get_profile_schoolclass_tabledata(@profile.id)
	###############################
	@schoolclasses = Schoolclass.all
	erb:profile_edit
end

#Folgende Route wird eigentlich nicht mehr benötigt, da Profil per Ajax aktualisiert wird
put '/profile/:id' do
  #Testausgabe der benannten Parameter
  #params[:profile]# + params[:hours].to_s
  profile = Profile.get(params[:id])
  #Im folgenden wird das Profil aktualisiert (nur der Name)
  profile.update(params[:profile])
end
#####################################################

get '/subject/:id/teacher_suggestions' do
    get_suggested_teachers_for(params[:id].to_i).to_s
end


helpers do

	def get_suggested_teachers_for(subject_id) #Hier wird bisher nur eine Liste der Fachlehrer zurückgegeben. Langfristig sollen es Empfehlungen aufgrund der Unterstunden sein.
		@subject_teachers=Department.all(:subject_id => subject_id)
		result="Unterstunden: "
		@subject_teachers.each do |teacher|	
			result= result+ Teacher.first(:id => teacher.teacher_id).shortcut.to_s + ", "
		end
		result=result[0...-2] + " Ueberstunden: "
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
					zeile = "<tr> <td><a href='/subject/"+subject.id.to_s+"' id='"+subject.id.to_s+"' class='tooltip'>" + subject.name + "</a></td>"
					@subject_teachers=Department.all(:subject_id => subject.id)
					@schoolclasses.each do |schoolclass|
						
						zeile = zeile + " <td>"
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

	# Die folgenden Funktionen werden für den view profile_edit benötigt
	def get_profile_schoolclass_tabledata(profile_id)
		@grades = Grade.all
		@schoolclasses_tabledata = []
		@grades.each do |grade|
			tabledata = "<td>"
			schoolclasses = Schoolclass.all(:grade_id => grade.id)
			schoolclasses.each do |schoolclass|
				profileassignment = Profileassignment.first(:profile_id.like => profile_id, :schoolclass_id => schoolclass.id)
				class_profilassignment = Profileassignment.first(:schoolclass_id => schoolclass.id)
				#Folgende Variable zeigt an, ob eine Klasse schon einem Profil zugeordnet ist
				#In layout.erb in der JS-Funktion getval_profil_class wird dies verwendet.
				#Eine Klasse darf nur einem Profil zugeordnet werden
				if class_profilassignment.nil? then
					class_has_profil = false
				else
					class_has_profil = true
				end
				name_class_field = profile_id.to_s + "_" + schoolclass.id.to_s + "_" + class_has_profil.to_s
				if profileassignment.nil? then
					tabledata = tabledata + "<font id='" + "class_" + schoolclass.id.to_s + "' color='#CCCCCC'>" + schoolclass.name + "</font>" + "&nbsp"
					checked = ''
				else
					tabledata = tabledata + "<font id='" + "class_" + schoolclass.id.to_s + "' color='#000000'>" + schoolclass.name + "</font>" + "&nbsp"
					checked = 'checked' 
				end
				tabledata = tabledata + "<input type='checkbox' name='" + name_class_field.to_s + "'" + checked + " onchange='getval_profil_class(this);'>" + "&nbsp"
			end
			tabledata = tabledata + "</td>"
			@schoolclasses_tabledata.push(tabledata)
		end
		return @schoolclasses_tabledata
	end

	def get_profile_subjects_hour_tabledata(profile_id)
		@subjects_hour_tabledata = []
		@subjects.each do |subject|
			profile_subject = Profilesubject.first(:profile_id => profile_id, :subject_id => subject.id)
			if profile_subject.nil? then
				tabledata = "<td><font  id='" + "subject_" + subject.id.to_s + "' color='#CCCCCC'>" + subject.name + "</font></td>"
			else
				tabledata = "<td><font  id='" + "subject_" + subject.id.to_s + "' color='#000000'>" + subject.name + "</font></td>"
			end
			tabledata = tabledata + "<td>"
			name_subject_hour_field = profile_id.to_s + "_" + subject.id.to_s + "_hours"
			if profile_subject.nil? then
				hours = '0'
			else
				hours = profile_subject.hours
			end
			tabledata = tabledata + "<input type='text' name=' " + name_subject_hour_field + "' onchange='getval_profil_subject_hour(this);' value =" + hours.to_s + ">"
			tabledata = tabledata + "</td>"
			@subjects_hour_tabledata.push(tabledata)
		end
		return @subjects_hour_tabledata
	end
	##########################################

	def get_active_term
		return Term.first(:is_active => true)
	end
end