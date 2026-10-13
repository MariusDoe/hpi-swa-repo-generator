Class {
	#name : #SRGGitLabGroup,
	#superclass : #Object,
	#instVars : [
		'gitLab',
		'id',
		'name'
	],
	#category : #SWARepoGenerator
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:41'
}
SRGGitLabGroup class >> fromResponse: aDictionary on: aGitLab [
	^ self
		newWithId: (aDictionary at: 'id')
		name: (aDictionary at: 'name')
		on: aGitLab
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:41'
}
SRGGitLabGroup class >> newWithId: aNumber name: aString on: aGitLab [
	^ self new
		gitLab: aGitLab;
		id: aNumber;
		name: aString;
		yourself
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:41'
}
SRGGitLabGroup class >> randomOn: aGitLab [
	| id |
	id := (1 to: 2000) atRandom.
	^ self
		newWithId: id
		name: ('group-{1}' format: {id})
		on: aGitLab
]

{
	#category : #members,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLabGroup >> addMember: usernameString role: roleNumber onError: aBlock [
	self gitLab
		post: ('groups/{1}/members' format: {self id})
		body: {'username' -> usernameString. 'access_level' -> roleNumber}
		onDryRun: []
		onError: aBlock.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:39'
}
SRGGitLabGroup >> gitLab [
	^ gitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:40'
}
SRGGitLabGroup >> gitLab: aGitLab [
	gitLab := aGitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:47'
}
SRGGitLabGroup >> id [
	^ id
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:26'
}
SRGGitLabGroup >> id: aNumber [
	id := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:47'
}
SRGGitLabGroup >> name [
	^ name
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:26'
}
SRGGitLabGroup >> name: aString [
	name := aString
]

{
	#category : #printing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:48'
}
SRGGitLabGroup >> printOn: aStream [
	aStream nextPutAll: self name.
]
