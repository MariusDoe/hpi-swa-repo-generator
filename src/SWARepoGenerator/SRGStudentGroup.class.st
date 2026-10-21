Class {
	#name : #SRGStudentGroup,
	#superclass : #Object,
	#instVars : [
		'generator',
		'students',
		'gitLabProject'
	],
	#category : #SWARepoGenerator
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/9/2026 17:17'
}
SRGStudentGroup class >> students: aCollection in: aRepoGenerator [
	^ self new
		generator: aRepoGenerator;
		students: aCollection;
		yourself
]

{
	#category : #gitlab,
	#'squeak_changestamp' : 'mad 10/21/2026 13:18'
}
SRGStudentGroup >> addMember: aStudent [
	aStudent gitLabName ifNil: [^ self logError: ('student {1} ({2}) has not GitLab name' format: {aStudent. self})].
	(self gitLabProject ifNil: [^ self logError: ('skipping adding {1} to {2}' format: {aStudent. self})])
		addMember: aStudent email
		role: SRGGitLab developerRole
		onError: [^ self logError: ('could not add {1} to {2}' format: {aStudent. self})].
]

{
	#category : #gitlab,
	#'squeak_changestamp' : 'mad 10/11/2026 21:45'
}
SRGStudentGroup >> addMembers [
	self gitLabProject ifNil: [^ self generator logError: ('skipping adding members to gitlab project for {1}, none exists' format: {self})].
	self students do: [:each | self addMember: each].
]

{
	#category : #gitlab,
	#'squeak_changestamp' : 'mad 10/20/2026 18:30'
}
SRGStudentGroup >> createSwaGitLabProject [
	self generator semesterGitLabGroup ifNil: [^ self logError: ('skipping creating SWA gitlab project for {1}, no semester group' format: {self})].
	self gitLabProject: (self gitLab createProject: self swaProjectName in: self generator semesterGitLabGroup).
	self gitLabProject unprotectBranch: 'main' onError: [].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 17:17'
}
SRGStudentGroup >> generator [
	^ generator
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGStudentGroup >> generator: aRepoGenerator [
	generator := aRepoGenerator
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:46'
}
SRGStudentGroup >> gitLab [
	^ self generator gitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:45'
}
SRGStudentGroup >> gitLabProject [
	^ gitLabProject
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:27'
}
SRGStudentGroup >> gitLabProject: aGitLabProject [
	gitLabProject := aGitLabProject
]

{
	#category : #logging,
	#'squeak_changestamp' : 'mad 10/9/2026 17:48'
}
SRGStudentGroup >> logError: aString [
	self generator logError: aString.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:19'
}
SRGStudentGroup >> number [
	^ self students anyOne groupNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:19'
}
SRGStudentGroup >> numberPadded [
	^ self number printStringPadded: 2
]

{
	#category : #printing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:20'
}
SRGStudentGroup >> printOn: aStream [
	aStream
		nextPutAll: 'Group ';
		nextPutAll: self numberPadded.
]

{
	#category : #gitlab,
	#'squeak_changestamp' : 'mad 10/11/2026 21:45'
}
SRGStudentGroup >> push [
	self gitLabProject ifNil: [^ self logError: ('skipping pushing of {1}, no gitlab project' format: {self})].
	self generator pushTo: self gitLabProject url.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 17:17'
}
SRGStudentGroup >> students [
	^ students
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGStudentGroup >> students: aCollection [
	students := aCollection
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:20'
}
SRGStudentGroup >> swaProjectName [
	^ 'swa{1}-{2}-group{3}' format: {
		Year current year.
		Year current year + 1 rem: 100.
		self numberPadded} 
]
