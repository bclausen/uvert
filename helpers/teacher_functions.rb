#Sammle alle Attributions eines Teachers zusammen
def get_all_attribution_by_teacher(teacher_id)
	teacher_attributions = Attribution.all(:teacher_id => teacher_id)
	return teacher_attributions
end

def get_teacher_overtime(teacher_id)
	overtime = 0
	#Bestimme Sollstunden über alle Terme
	teacher_loads = 0
	teacher_workloads = Workload.all(:teacher_id => teacher_id)
	teacher_workloads.each do |tw|
		teacher_loads = teacher_loads + tw.load
	end
	#Bestimme gegebene Unterrichtsstunden über alle Terme
	teacher_hours = 0
	teacher_attributions = get_all_attribution_by_teacher(teacher_id)
	teacher_attributions.each do |ta|
		ta_profileassignment_id = ta.profileassignment_id
		ta_profile_id = Profileassignment.first(:id => ta_profileassignment_id ).profile_id
		ta_hours = Profilesubject.first(:profile_id => ta_profile_id, :subject_id => ta.subject_id).hours
		teacher_hours = teacher_hours + ta_hours
	end
	#Bestimme Ermäßigungen über alle Terme
	teacher_compensation_hours = 0
	teacher_compensations = Compensation.all(:teacher_id => teacher_id)
	teacher_compensations.each do |tc|
		teacher_compensation_hours = teacher_compensation_hours + tc.hours
	end
	#Bestimme AG-Stunden über alle Terme
	#Bestimme Kurs-Stunden über alle 

	#Berechne Überstunden über alle Unterrichtsverteilungen
	overtime = teacher_loads - teacher_hours-teacher_compensation_hours
	return overtime
end

def get_term_attribution_by_teacher(term_id, teacher_id)

end

def get_overtime_by_teacher(teacher_id)

end