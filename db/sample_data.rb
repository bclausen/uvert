#!/bin/env ruby
# encoding: utf-8

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
#In dieser Datei werden die Beispieldaten geführt und in die DB eingetragen.

#BEISPIELDATEN

teacherList = [
	["Ahlers","Regina","AHS",rand(6),8 + rand(15),true,["ENG","GEO"]],
	["Arnhold","Marieke","ARN",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Bachmann","Charlotte","BAC",rand(6),8 + rand(15),false,["MAT","WPO"]],
	["Bartosch","Lorenz","BAR",rand(6),8 + rand(15),true,["MAT","PHY"]],
	["Beck","Barbara","BEK",rand(6),8 + rand(15),true,["ENG","GEO"]],
	["Beckershaus","Susanne","BHS",rand(6),8 + rand(15),true,["DEU","REV"]],
	["Bendig","Anla","BEN",rand(6),8 + rand(15),true,["DEU","CHE"]],
	["Beyer","Sonja","BEY",rand(6),8 + rand(15),true,["DEU","ENG"]],
	["Biegel","Peter","BIE",rand(6),8 + rand(15),true,["MAT","CHE"]],
	["Bohlken","Christine","BOH",rand(6),8 + rand(15),true,["DEU","BIO","DAE"]],
	["Bornemann","Karsten","BOR",rand(6),8 + rand(15),true,["BIO","GEO"]],
	["Brügmann","Julia","BRM",rand(6),8 + rand(15),true,["ENG","GEO"]],
	["Burchardi","Martina","BUR",rand(6),8 + rand(15),true,["DEU","GES"]],
	["Celik","Corinna","CEL",rand(6),8 + rand(15),true,["SPA","FRA"]],
	["Clausen","Bernd","CLS",rand(6),8 + rand(15),true,["MAT","INF","GEO"]],
	["Clausen","Tanja","CL",rand(6),8 + rand(15),true,["DEU","SPO"]],
	["Dammermann","Friederike","DA",rand(6),8 + rand(15),true,["DEU","KUN"]],
	["Dwinger","Stephanie","DWI",rand(6),8 + rand(15),false,["GEO","ENG"]],
	["Eckert","Markus","ECK",rand(6),8 + rand(15),true,["DEU","WPO"]],
	["Emmerling","Simon","EM",rand(6),8 + rand(15),true,["DEU","WPO"]],
	["Erdmann","Fionn","ERD",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Ernst","Ines","ENT",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Ernst","Manfred","EST",rand(6),8 + rand(15),true,["MAT","PHY"]],
	["Fischer","Caroline","FSH",rand(6),8 + rand(15),true,["DEU","FRA"]],
	["Fischer","Matthias","FIS",rand(6),8 + rand(15),true,["DEU","GES"]],
	["Folger","Laila","FLR",rand(6),8 + rand(15),true,["ENG","RUS"]],
	["Gade","Dietlind","GDE",rand(6),8 + rand(15),true,["DEU","LAT","PHI"]],
	["Glöckner","Bert","GLR",rand(6),8 + rand(15),true,["REV","GES"]],
	["Gödde","Christa","GÖD",rand(6),8 + rand(15),true,["RKA"]],
	["Gröning","Julian","GRÖ",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Hafner","Sonja","HAF",rand(6),8 + rand(15),true,["ENG","BIO"]],
	["Hambruch","Sabine","HAM",rand(6),8 + rand(15),true,["ENG","SPA", "DSP"]],
	["Hansen","Henning","HHN",rand(6),8 + rand(15),true,["WPO","GES"]],
	["von Hassel","Frank","HAS",rand(6),8 + rand(15),true,["WPO","GES", "SPO"]],
	["Henrici","Sabine","HEC",rand(6),8 + rand(15),true,["FRA","ENG"]],
	["Hoffmann","Michael","HFM",rand(6),8 + rand(15),true,["LAT","GES"]],
	["Hofmann","Arne","HOF",rand(6),8 + rand(15),true,["ENG","SPO"]],
	["Huczko","Stephan","HUK",rand(6),8 + rand(15),true,["BIO","CHE"]],
	["Imhoff","Corinna","IMH",rand(6),8 + rand(15),true,["ENG","DEU"]],
	["Jars","Peter","JAR",rand(6),8 + rand(15),true,["GEO","ENG"]],
	["Junk","Tim","JK",rand(6),8 + rand(15),true,["LAT","GES"]],
	["Kaulbach","Jutta","KBH",rand(6),8 + rand(15),true,["ENG","DAE"]],
	["Kirchner","Ellinor","KIR",rand(6),8 + rand(15),true,["MAT","ENG"]],
	["Kirchner","Eva Viktoria","KRN",rand(6),8 + rand(15),true,["ENG","GEO"]],
	["Kleidt","Sandra","KLE",rand(6),8 + rand(15),true,["DAE","DEU"]],
	["Knetter","Thorsten","KTR",rand(6),8 + rand(15),true,["MAT","PHY"]],
	["Körber","Mirko","KBR",rand(6),8 + rand(15),true,["MAT","PHI"]],
	["Kostrewa","Herma","KOS",rand(6),8 + rand(15),true,["DEU","FRA"]],
	["Kraus","Geelke","KRA",rand(6),8 + rand(15),true,["DEU","BIO"]],
	["Kuchcinski","Gyde","SKI",rand(6),8 + rand(15),true,["DEU","ENG"]],
	["Kuckuck","Karl","KUCK",rand(6),8 + rand(15),true,["DEU","KUN"]],
	["Kühl","Nadja","KUE",rand(6),8 + rand(15),true,["BIO","SPA"]],
	["Kuhnke","Swantje","KNK",rand(6),8 + rand(15),true,["KUN","ENG"]],
	["Kuhr","Sina","KR",rand(6),8 + rand(15),true,["GES","DSP", "FRA"]],
	["Kurz","Anke","KUZ",rand(6),8 + rand(15),true,["DEU","WPO"]],
	["Liebettrau","Kurt","LIE",rand(6),8 + rand(15),true,["MAT","PHY"]],
	["Lorenz","Kathrin","LON",rand(6),8 + rand(15),true,["ENG","SPO"]],
	["Lorentzen","Birgit","LOR",rand(6),8 + rand(15),true,["ENG","PHY"]],
	["Mailand","Britta","MLB",rand(6),8 + rand(15),true,["SPA","DEU","DSP"]],
	["Mailand","Steffen","MLS",rand(6),8 + rand(15),true,["SPA","DAE"]],
	["Melsbach","Alexandra","MEB",rand(6),8 + rand(15),true,["MAT","PHY"]],
	["Meyer","Arno","M",rand(6),8 + rand(15),true,["DEU","REV"]],
	["Nietsch","Bosse","NTH",rand(6),8 + rand(15),true,["BIO","CHE"]],
	["Oborski","Frank","OBK",rand(6),8 + rand(15),true,["LAT","KUN"]],
	["Päßler","Dieter","PL",rand(6),8 + rand(15),true,["GEO","ENG"]],
	["Petersen","Ulrike","PET",rand(6),8 + rand(15),true,["MUS","ENG"]],
	["Plötz","Christine","PTZ",rand(6),8 + rand(15),true,["BIO","DEU"]],
	["Räker","Timo","RKR",rand(6),8 + rand(15),true,["MAT","INF","WPO"]],
	["Reese","Claudia","REE",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Schmidt","Christoph","SMD",rand(6),8 + rand(15),true,["MUS"]],
	["Shehata","Lilian","SHT",rand(6),8 + rand(15),true,["BIO","CHE"]],
	["Spevak","Christian","SPE",rand(6),8 + rand(15),true,["MUS","PHY"]],
	["Spring","Kristina","SPR",rand(6),8 + rand(15),true,["MUS","DSP","ENG"]],
	["Stephanidis","Anja","STE",rand(6),8 + rand(15),true,["MAT","SPO"]],
	["Wedler","Janne","WLR",rand(6),8 + rand(15),true,["DEU","SPO"]],
]

subjectList = [
	["ReligionEV", "REV"],
	["ReligionKA", "RKA"],
	["Philosophie", "PHI"],
	["Deutsch", "DEU"],
	["Wirtschaft/Politik", "WPO"],
	["Geschichte", "GES"],
	["Geographie", "GEO"],
	["Geographie bilingual", "GEObil"],
	["Bili Vorkurs", "Bili"],
	["Englisch", "ENG"],
	["Französisch", "FRA"],
	["Latein", "LAT"],
	["Dänisch", "DAE"],
	["Spanisch", "SPA"],
	["Mathematik", "MAT"],
	["Physik", "PHY"],
	["Physik bilingual", "PHYbil"],
	["Chemie", "CHE"],
	["Biologie", "BIO"],
	["Informatik", "INF"],
	["Musik", "MUS"],
	["Kunst", "KUN"],
	["Sport", "SPO"],
	["Seminarfach", "SEM"],
	["Darstellendes Spiel", "DSP"],
	["Russisch", "RUS"]
]

profileList = [
		["Klasse 10 Sprache",["10 a"], [["BIO",3],["CHE",0],["DSP",0],["DEU",3],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]], 
		["Klasse 10 Nawi",["10 e"], [["BIO",3],["CHE",0],["DSP",0],["DEU",3],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
		["Klasse 10 Gesell",["10 b"], [["BIO",3],["CHE",0],["DSP",0],["DEU",3],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
		["Klasse 10 Gesell2",["10 c"], [["BIO",3],["CHE",0],["DSP",0],["DEU",3],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
		["Klasse 10 Ästh",["10 d"], [["BIO",3],["CHE",0],["DSP",0],["DEU",3],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
							# Klassen 5 am 17.8. aktualisiert
		["Klasse 5 Mus",["5 a","5 c"], [["BIO",3],["Bili",0],["CHE",0],["DSP",2],["DEU",6],["DAE",0],["ENG",6],["FRA",0],
		["GEO",0],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",5],["MUS",3],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
		["Klasse 5 Werken",["5 b"], [["BIO",3],["Bili",0],["CHE",0],["DSP",0],["DEU",6],["DAE",0],["ENG",6],["FRA",0],
		["GEO",0],["GES",2],["INF",0],["KUN",3],["LAT",0],["MAT",5],["MUS",2],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
		["Klasse 5 Akrobatik",["5 d"], [["BIO",3],["Bili",0],["CHE",0],["DSP",0],["DEU",6],["DAE",0],["ENG",6],["FRA",0],
		["GEO",0],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",5],["MUS",2],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",3],["WPO",0]]],
							# Klassen 6 am 17.8. aktualisiert
		["Klasse 6 Akrobatik",["6 a"], [["BIO",2],["Bili",1],["CHE",0],["DSP",0],["DEU",4],["DAE",0],["ENG",4],["FRA",0],
		["GEO",2],["GES",0],["INF",0],["KUN",2],["LAT",0],["MAT",6],["MUS",2],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",3],["WPO",0]]],
		["Klasse 6 Musik",["6 b"], [["BIO",2],["Bili",1],["CHE",0],["DSP",0],["DEU",4],["DAE",0],["ENG",4],["FRA",0],
		["GEO",2],["GES",0],["INF",0],["KUN",2],["LAT",0],["MAT",6],["MUS",3],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
		["Klasse 6 DSP",["6 c","6 d"], [["BIO",2],["Bili",1],["CHE",0],["DSP",2],["DEU",4],["DAE",0],["ENG",4],["FRA",0],
		["GEO",2],["GES",0],["INF",0],["KUN",2],["LAT",0],["MAT",6],["MUS",1],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
		["Klasse 6 Werken",["6 d"], [["BIO",2],["Bili",1],["CHE",0],["DSP",0],["DEU",4],["DAE",0],["ENG",4],["FRA",0],
		["GEO",2],["GES",0],["INF",0],["KUN",3],["LAT",0],["MAT",6],["MUS",2],["PHI",0],["PHY",0],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
							# Klassen 7 am 17.8. aktualisiert
		["Klasse 7",["7 a","7 b","7 c","7 d"], [["BIO",0],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEObil",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",2],["PHI",0],["PHY",2],
		["REV",2],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
							# Klassen 8 am 17.8. aktualisiert
		["Klasse 8 Wipo",["8 a","8 b"], [["BIO",2],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEObil",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",0],["PHY",2],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
		["Klasse 8 Phil PHYbil",["8 c"], [["BIO",2],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEObil",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",2],["PHY",0],["PHYbil",2],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
		["Klasse 8 Phil",["8 d"], [["BIO",2],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEObil",2],["GES",2],["INF",0],["KUN",2],["LAT",0],["MAT",4],["MUS",0],["PHI",2],["PHY",2],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",0]]],
							# Klassen 9 am 17.8. aktualisiert
		["Klasse 9 PHYbil",["9 a"], [["BIO",2],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEO",2],["GES",2],["INF",0],["KUN",0],["LAT",0],["MAT",4],["MUS",2],["PHI",2],["PHY",0],["PHYbil",2],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
		["Klasse 9",["9 b","9 c","9 d","9 e"], [["BIO",2],["CHE",2],["DSP",0],["DEU",4],["DAE",0],["ENG",3],["FRA",0],
		["GEObil",2],["GES",2],["INF",0],["KUN",0],["LAT",0],["MAT",4],["MUS",2],["PHI",2],["PHY",2],["PHYbil",0],
		["REV",0],["RKA",0],["SEM",0],["SPA",0],["SPO",2],["WPO",2]]],
	]

gradeList = [
	["5","false"],
	["6","false"],
	["7","false"],
	["8","false"],
	["9","false"],
	["10","true"],
	["11","true"],
	["12","true"],
	["13","true"],
	["E","true"]
]

schoolclassList = [
	["5 a", "6 a", "5"],
	["5 b", "6 b", "5"],
	["5 c", "6 c", "5"],
	["5 d", "6 d", "5"],
	["5 e", "6 e", "5"],
	["6 a", "7 a", "6"],
	["6 b", "7 b", "6"],
	["6 c", "7 c", "6"],
	["6 d", "7 d", "6"],
	["6 e", "7 e", "6"],
	["7 a", "8 a", "7"],
	["7 b", "8 b", "7"],
	["7 c", "8 c", "7"],
	["7 d", "8 d", "7"],
	["7 e", "8 e", "7"],
	["8 a", "9 a", "8"],
	["8 b", "9 b", "8"],
	["8 c", "9 c", "8"],
	["8 d", "9 d", "8"],
	["8 e", "9 e", "8"],
	["9 a", "", "9"],
	["9 b", "", "9"],
	["9 c", "", "9"],
	["9 d", "", "9"],
	["9 e", "", "9"],
	["10 a", "11 a", "10"],
	["10 b", "11 b", "10"],
	["10 b", "11 b", "10"],
	["10 c", "11 c", "10"],
	["10 d", "11 d", "10"],
	["10 e", "11 e", "10"],
	["13 a", "", "13"],
	["13 b", "", "13"],
	["13 c", "", "13"],
	["13 d", "", "13"],
	["13 e", "", "13"],
	["E 1", "", "12"],
	["E 2", "", "12"],
	["E 3", "", "12"],
	["E 4", "", "12"],
	["E 5", "", "12"],
	["E 6", "", "12"],
	["E 7", "", "12"],
	["E 8", "", "12"],
	["E 9", "", "12"]
]

termList = [
	["2. Hlbj. 2014/15","01.02.2015","31.07.2015",false],
	["1. Hlbj. 2015/16","01.08.2015","31.01.2016",true]
]


#ENDE DER BEISPIELDATEN - BEGINN DER EINSPEICHERUNG

termList.each do |term|
	Term.create( :name => term[0], :start_date => term[1], :end_date => term[2], :is_active => term[3] )
end

gradeList.each do |grade|
	Grade.create( :name => grade[0], :is_levelII => grade[1] )
end

schoolclassList.each do |schoolclass|
	gradeID = Grade.first(name: schoolclass[2]).id
	Schoolclass.create( :name => schoolclass[0], :successor => schoolclass[1], :grade_id => gradeID )
end

subjectList.each do |subject|
	Subject.create( :name => subject[0], :shortcut => subject[1] )
end

profileList.each do |profile|
	#Erstellen eines neuen Profils
	Profile.create(name: profile[0], term_id: Term.first(is_active: true).id)
	#Zuordnung zu angebenen Klassen
	if profile[1].size != 0 then
		profile[1].each do |schoolClass|
			Profileassignment.create(profile_id: Profile.first(name: profile[0]).id, schoolclass_id: Schoolclass.first(name: schoolClass).id)
		end
	end
 	#Fächer und Stündigkeit anlegen
	if profile[2].size != 0 then
		profile[2].each do |subjectShortcutHour|
			if subjectShortcutHour[1] != 0 then
				Profilesubject.create(profile_id: Profile.first(name: profile[0]).id, subject_id: Subject.first(shortcut: subjectShortcutHour[0]).id, hours: subjectShortcutHour[1])
			end
		end
	end
end

#Erstelle Beispiellehrer, teacherActives, departments und workloads
teacherList.each do |teacher|
	puts("Teacher.create(lastname:"+ teacher[0].to_s+", firstname:"+teacher[1].to_s+", shortcut:"+teacher[2].to_s+")")
	Teacher.create(lastname: teacher[0], firstname:teacher[1], shortcut:teacher[2])
	@new_teacher=Teacher.first(shortcut: teacher[2])
	if teacher[4] then
		TeacherActive.create(teacher_id: @new_teacher.id , term_id: Term.first(is_active: true).id)
		Workload.create(teacher_id: @new_teacher.id , load: teacher[4], term_id: Term.first(is_active: true).id)
	end
	subjectsArray=teacher[6]
	if subjectsArray.size != 0 then
			subjectsArray.each do |subjectShortcut|
				@t_subject=Subject.first(shortcut: subjectShortcut)
				Department.create(teacher_id: @new_teacher.id , subject_id:@t_subject.id)
			end
		end
end