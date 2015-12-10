#!/bin/env ruby
# encoding: utf-8


#Bei der Ausführung dieser Datein wird 'uvert.db' entsprechend der Vorgaben in den Klassen (teachers, usw) erstellt.
require '../classes/attributions'
require '../classes/compensations'
require '../classes/departments'
require '../classes/grades'
require '../classes/profileassignments'
require '../classes/profiles'
require '../classes/profilesubjects'
require '../classes/schoolclasses'
require '../classes/subjects'
require '../classes/teacherActives'
require '../classes/teachers'
require '../classes/terms'
require '../classes/workloads'

Attribution.auto_migrate!
Compensation.auto_migrate!
Department.auto_migrate!
Grade.auto_migrate!
Profileassignment.auto_migrate!
Profile.auto_migrate!
Profilesubject.auto_migrate!
Schoolclass.auto_migrate!
Subject.auto_migrate!
TeacherActive.auto_migrate!
Teacher.auto_migrate!
Term.auto_migrate!
Workload.auto_migrate!
DataMapper.finalize