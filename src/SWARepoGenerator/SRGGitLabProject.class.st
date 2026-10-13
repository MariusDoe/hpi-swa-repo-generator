Class {
	#name : #SRGGitLabProject,
	#superclass : #Object,
	#instVars : [
		'gitLab',
		'id',
		'name',
		'url'
	],
	#category : #SWARepoGenerator
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:42'
}
SRGGitLabProject class >> fromResponse: aDictionary on: aGitLab [
	^ self
		newWithId: (aDictionary at: 'id')
		name: (aDictionary at: 'name')
		url: (aDictionary at: 'http_url_to_repo')
		on: aGitLab
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:42'
}
SRGGitLabProject class >> newWithId: aNumber name: nameString url: urlString on: aGitLab [
	^ self new
		gitLab: aGitLab;
		id: aNumber;
		name: nameString;
		url: urlString;
		yourself
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/11/2026 21:42'
}
SRGGitLabProject class >> randomOn: aGitLab [
	| id |
	id := (1 to: 2000) atRandom.
	^ self
		newWithId: id
		name: ('project-{1}' format: {id})
		url: ('https://example.com/project-{1}.git' format: {id})
		on: aGitLab
]

{
	#category : #members,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLabProject >> addMember: usernameString role: roleNumber onError: aBlock [
	self gitLab
		post: ('projects/{1}/members' format: {self id})
		body: {'username' -> usernameString. 'access_level' -> roleNumber}
		onDryRun: []
		onError: aBlock.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLabProject >> gitLab [
	^ gitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLabProject >> gitLab: aGitLab [
	gitLab := aGitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:38'
}
SRGGitLabProject >> id [
	^ id
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:26'
}
SRGGitLabProject >> id: aNumber [
	id := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:42'
}
SRGGitLabProject >> name [
	^ name
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:26'
}
SRGGitLabProject >> name: aString [
	name := aString
]

{
	#category : #printing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:43'
}
SRGGitLabProject >> printOn: aStream [
	aStream nextPutAll: self name.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 19:38'
}
SRGGitLabProject >> url [
	^ url
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/13/2026 15:26'
}
SRGGitLabProject >> url: aString [
	url := aString
]
