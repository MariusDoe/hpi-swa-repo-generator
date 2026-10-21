Class {
	#name : #SRGGitLab,
	#superclass : #Object,
	#instVars : [
		'generator',
		'token'
	],
	#category : #SWARepoGenerator
}

{
	#category : #roles,
	#'squeak_changestamp' : 'mad 10/9/2026 17:24'
}
SRGGitLab class >> developerRole [
	^ 30
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'mad 10/10/2026 20:27'
}
SRGGitLab class >> for: aRepoGenerator [
	^ self new
		generator: aRepoGenerator;
		yourself
]

{
	#category : #roles,
	#'squeak_changestamp' : 'mad 10/9/2026 17:24'
}
SRGGitLab class >> maintainerRole [
	^ 40
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/9/2026 16:55'
}
SRGGitLab >> addTokenTo: aWebRequest [
	aWebRequest headerAt: 'PRIVATE-TOKEN' put: self token.
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/10/2026 20:06'
}
SRGGitLab >> apiUrl: aString [
	^ 'https://gitlab.hpi.de/api/v4/', aString
]

{
	#category : #groups,
	#'squeak_changestamp' : 'mad 10/20/2026 17:05'
}
SRGGitLab >> createGroup [
	| groupName groupPath parentGroup |
	groupName := Project uiManager request: 'Group name:'.
	groupPath := Project uiManager
		request: 'Path for group:'
		initialAnswer: (groupName asLowercase copyWithRegex: '[^-a-zA-Z0-9]' matchesReplacedWith: '-').
	parentGroup := self requestGroup: 'Parent group:'.
	^ self createGroup: groupName path: groupPath in: parentGroup
]

{
	#category : #groups,
	#'squeak_changestamp' : 'mad 10/11/2026 21:37'
}
SRGGitLab >> createGroup: nameString in: parentGroup [
	| body |
	body := {'name' -> nameString}.
	parentGroup ifNotNil: [body := body copyWith: 'parent_id' -> parentGroup id].
	^ SRGGitLabGroup
		fromResponse: (self
			post: 'groups'
			body: body
			onDryRun: [^ SRGGitLabGroup randomOn: self]
			onError: [self logError: ('could not create group {1}' format: {nameString}). ^ nil])
		on: self
]

{
	#category : #groups,
	#'squeak_changestamp' : 'mad 10/20/2026 16:51'
}
SRGGitLab >> createGroup: nameString path: pathString in: parentGroup [
	| body |
	body := {'name' -> nameString. 'path' -> pathString}.
	parentGroup ifNotNil: [body := body copyWith: 'parent_id' -> parentGroup id].
	^ SRGGitLabGroup
		fromResponse: (self
			post: 'groups'
			body: body
			onDryRun: [^ SRGGitLabGroup randomOn: self]
			onError: [self logError: ('could not create group {1}' format: {nameString}). ^ nil])
		on: self
]

{
	#category : #projects,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLab >> createProject: nameString in: parentGroup [
	^ SRGGitLabProject
		fromResponse: (self
			post: 'projects'
			body: {'name' -> nameString. 'namespace_id' -> parentGroup id}
			onDryRun: [^ SRGGitLabProject randomOn: self]
			onError: [self logError: ('could not create project {1}' format: {nameString}). ^ nil])
		on: self
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/21/2026 12:32'
}
SRGGitLab >> delete: apiRouteString onDryRun: dryRunBlock onError: errorBlock [
	self dryRun ifTrue: [
		self logError: ('dry run: running DELETE {1}' format: {apiRouteString}).
		^ dryRunBlock value].
	^ self
		handleResponse: (WebClient new
			httpDelete: (self apiUrl: apiRouteString)
			do: [:request | self addTokenTo: request])
		onError: errorBlock
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:04'
}
SRGGitLab >> dryRun [
	^ self generator dryRun
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:04'
}
SRGGitLab >> generator [
	^ generator
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:20'
}
SRGGitLab >> generator: aRepoGenerator [
	generator := aRepoGenerator
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/10/2026 20:06'
}
SRGGitLab >> get: apiRouteString onError: aBlock [
	^ self
		handleResponse: (WebClient new
			httpGet: (self apiUrl: apiRouteString)
			do: [:request | self addTokenTo: request])
		onError: aBlock
]

{
	#category : #groups,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGGitLab >> groups [
	^ (self get: 'groups' onError: [self logError: 'could not list groups'. ^ nil])
		collect: [:each | SRGGitLabGroup fromResponse: each on: self]
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/9/2026 18:00'
}
SRGGitLab >> handleResponse: aWebResponse onError: aBlock [
	aWebResponse isSuccess ifTrue: [^ aWebResponse content parseAsJson].
	self logError: ('got status {1} (body: {2}) to request {3} (body: {4})' format: {
		aWebResponse status.
		aWebResponse content printString.
		aWebResponse request url.
		(aWebResponse request isPostRequest
			ifTrue: [aWebResponse request content]
			ifFalse: ['']) printString}).
	^ aBlock cull: aWebResponse
]

{
	#category : #logging,
	#'squeak_changestamp' : 'mad 10/10/2026 20:04'
}
SRGGitLab >> logError: aString [
	self generator logError: aString.
]

{
	#category : #api,
	#'squeak_changestamp' : 'mad 10/10/2026 20:06'
}
SRGGitLab >> post: apiRouteString body: aJsonObject onDryRun: dryRunBlock onError: errorBlock [
	self dryRun ifTrue: [
		self logError: ('dry run: running POST {1} (body: {2})' format: {apiRouteString. aJsonObject asJsonString}).
		^ dryRunBlock value].
	^ self
		handleResponse: (WebClient new
			httpPost: (self apiUrl: apiRouteString)
			content: aJsonObject asJsonString
			type: 'application/json'
			do: [:request | self addTokenTo: request])
		onError: errorBlock
]

{
	#category : #groups,
	#'squeak_changestamp' : 'mad 10/21/2026 12:22'
}
SRGGitLab >> requestGroup: titleString [
	| groups result |
	groups := (self groups ifNil: [^ nil]) sorted: #name ascending.
	result := Project uiManager
		chooseFrom: ((groups collect: #name) copyWith: 'Create new')
		values: (groups copyWith: #new)
		title: titleString.
	result = #new ifTrue: [^ self createGroup].
	^ result
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:03'
}
SRGGitLab >> token [
	^ token
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:20'
}
SRGGitLab >> token: aString [
	token := aString
]

{
	#category : #token,
	#'squeak_changestamp' : 'mad 10/21/2026 13:22'
}
SRGGitLab >> tokenFromUser [
	self token: (Project uiManager requestPassword: 'GitLab token:').
]
