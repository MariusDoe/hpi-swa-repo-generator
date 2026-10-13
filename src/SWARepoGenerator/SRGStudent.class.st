Class {
	#name : #SRGStudent,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'lastName',
		'email',
		'groupNumber'
	],
	#category : #SWARepoGenerator
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/10/2026 20:25'
}
SRGStudent class >> fromJson: aDictionary [ 
	^ self new
		firstName: (aDictionary at: 'firstname');
		lastName: (aDictionary at: 'lastname');
		email: (aDictionary at: 'emailaddress');
		groupNumberFrom: (aDictionary at: 'groups');
		yourself
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 14:54'
}
SRGStudent >> email [
	^ email
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGStudent >> email: aString [
	email := aString
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 15:06'
}
SRGStudent >> firstName [
	^ firstName
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGStudent >> firstName: aString [
	firstName := aString
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:44'
}
SRGStudent >> gitLabName [
	self isAtHPI ifFalse: [^ nil].
	^ self email copyUpTo: $@
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:18'
}
SRGStudent >> groupNumber [
	^ groupNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:18'
}
SRGStudent >> groupNumber: aNumber [
	groupNumber := aNumber
]

{
	#category : #parsing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:24'
}
SRGStudent >> groupNumberFrom: aString [
	self groupNumber: (self parseGroupNumber: aString).
]

{
	#category : #testing,
	#'squeak_changestamp' : 'mad 10/10/2026 23:46'
}
SRGStudent >> isAtHPI [
	^ #('@hpi.de' '@hpi.uni-potsdam.de' '@student.hpi.de' '@student.hpi.uni-potsdam.de')
		anySatisfy: [:suffix | self email endsWith: suffix]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 15:06'
}
SRGStudent >> lastName [
	^ lastName
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGStudent >> lastName: aString [
	lastName := aString
]

{
	#category : #parsing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:20'
}
SRGStudent >> parseGroupNumber: aString [ 
	| matcher |
	aString ifNil: [^ nil].
	matcher := 'Gruppe (\d+).*' asRegex.
	(matcher matches: aString) ifFalse: [^ nil].
	^ (matcher subexpression: 2) asInteger
]

{
	#category : #printing,
	#'squeak_changestamp' : 'mad 10/9/2026 15:07'
}
SRGStudent >> printOn: aStream [
	aStream
		nextPutAll: self firstName;
		space;
		nextPutAll: self lastName.
]
