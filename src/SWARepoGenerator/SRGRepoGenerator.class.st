Class {
	#name : #SRGRepoGenerator,
	#superclass : #Object,
	#instVars : [
		'workingCopy',
		'initialHeadCommit',
		'students',
		'gitLab',
		'dryRun',
		'semesterGitLabGroup',
		'log'
	],
	#category : #SWARepoGenerator
}

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/13/2026 15:17'
}
SRGRepoGenerator class >> runForSwa [
	^ self new runForSwa
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/10/2026 20:44'
}
SRGRepoGenerator >> acceptChangesDialogDuring: aBlock [
	aBlock
		on: GSPendingChangesEmpty
		do: #resume
		on: GSPendingChangesOpenDialog
		do: [:notification |
			notification pendingChanges checkedAction.
			notification resume].
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 21:45'
}
SRGRepoGenerator >> addMembersToSemesterGitLabGroup: aCollection [
	self semesterGitLabGroup ifNil: [^ self logError: 'skipping adding members to semester group'].
	aCollection do: [:each |
		self semesterGitLabGroup
			addMember: each gitLabName
			role: SRGGitLab maintainerRole
			onError: [self logError: ('could not add {1} to semester group' format: {each})]].
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/13/2026 15:35'
}
SRGRepoGenerator >> addTutorsToSemesterGitLabGroup [
	self addMembersToSemesterGitLabGroup: (self selectTutors ifNil: [^ self]).
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/9/2026 18:51'
}
SRGRepoGenerator >> amend [
	self acceptChangesDialogDuring: [self workingCopy operationStarter actionCommitAmend]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:30'
}
SRGRepoGenerator >> dryRun [
	^ dryRun
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:37'
}
SRGRepoGenerator >> dryRun: aBoolean [
	dryRun := aBoolean
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 00:18'
}
SRGRepoGenerator >> dryRunFromUser [
	self dryRun: ((Project uiManager
		chooseOptionFrom: #('Dry run' 'Actual run')
		values: #(true false)
		title: 'Do you want to actually run the generator or perform a dry run?') ifNil: [true]).
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:42'
}
SRGRepoGenerator >> gitLab [
	^ gitLab
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:42'
}
SRGRepoGenerator >> gitLab: aGitLab [
	gitLab := aGitLab
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 21:43'
}
SRGRepoGenerator >> gitLabTokenFromUser [
	self gitLab tokenFromUser.
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 21:46'
}
SRGRepoGenerator >> handleStudentGroupForSwa: aStudentGroup [
	| projectAndPackageName |
	projectAndPackageName := 'SWAGroup{1}' format: {aStudentGroup numberPadded}.
	self
		reset;
		renameProjectTo: projectAndPackageName;
		renamePackage: 'SWAGroup01' to: projectAndPackageName;
		amend.
	aStudentGroup
		createSwaGitLabProject;
		addMembers;
		push.
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/10/2026 20:38'
}
SRGRepoGenerator >> handleStudentGroupsForSwa [
	self studentGroups
		do: [:each | self handleStudentGroupForSwa: each]
		displayingProgress: [:each | 'Processing {1}' format: {each}].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:37'
}
SRGRepoGenerator >> initialHeadCommit [
	^ initialHeadCommit
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:37'
}
SRGRepoGenerator >> initialHeadCommit: aGitCommit [
	initialHeadCommit := aGitCommit
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'mad 10/11/2026 21:39'
}
SRGRepoGenerator >> initialize [
	super initialize.
	self
		dryRun: true;
		gitLab: (SRGGitLab for: self);
		log: OrderedCollection new.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 17:57'
}
SRGRepoGenerator >> log [
	^ log
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:37'
}
SRGRepoGenerator >> log: aCollection [
	log := aCollection
]

{
	#category : #logging,
	#'squeak_changestamp' : 'mad 10/9/2026 17:42'
}
SRGRepoGenerator >> logError: aString [
	self log add: aString.
]

{
	#category : #moodle,
	#'squeak_changestamp' : 'mad 10/13/2026 15:37'
}
SRGRepoGenerator >> parseMoodleGroupsFromJson: aJsonObject [
	^ aJsonObject first collect: [:each | SRGStudent fromJson: each].
]

{
	#category : #moodle,
	#'squeak_changestamp' : 'mad 10/13/2026 15:37'
}
SRGRepoGenerator >> parseMoodleGroupsFromRequestedFile [
	^ FileStream
		fileNamed: ((Project uiManager chooseFileMatchingSuffixes: #('json') label: 'Moodle Groups File (json). Go to the Moodle course > Participants, scroll down, click ''Select all N users'', scroll down again, next to ''With selected users....'' select ''Download table data as > Javascript Object Notation (.json)''.') ifNil: [^ #()])
		do: [:stream | self parseMoodleGroupsFromStream: stream]
]

{
	#category : #moodle,
	#'squeak_changestamp' : 'mad 10/13/2026 15:37'
}
SRGRepoGenerator >> parseMoodleGroupsFromStream: aStream [
	^ self parseMoodleGroupsFromJson: (Json readFrom: aStream)
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/11/2026 21:38'
}
SRGRepoGenerator >> pushTo: urlString [
	| remoteName |
	self dryRun ifTrue: [^ self logError: ('dry run: pushing to {1}' format: {urlString})].
	remoteName := 'gitlab'.
	self workingCopy operationStarter in: [:repo |
		[repo unitOfWork
			addRemote: remoteName url: urlString;
			push: repo currentBranchOrCancel toRemote: remoteName]
				on: NeedGitCredentials
				do: [:notification |
					"GitLab does not validate the username"
					notification resume: 'any_non_empty_string' -> self gitLab token]].
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/21/2026 13:46'
}
SRGRepoGenerator >> renameClassCategory: oldString to: newString [
	((self environment organization categories
		select: [:each | each = oldString or: [each beginsWith: oldString, '-']])
		sorted: #size descending) "sub-categories first, otherwise rename will be a no-op"
		do: [:each | | newName |
			newName := newString, (each allButFirst: oldString size).
			self assert: (self environment organization categories includes: newName) not.
			self environment organization renameCategory: each toBe: newName].
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/9/2026 14:23'
}
SRGRepoGenerator >> renamePackage: oldString to: newString [
	| mapper |
	mapper := self workingCopy mappers detect: [:each | (each isKindOf: GSCodeMapper) and: [each package name = oldString]].
	self renameClassCategory: oldString to: newString.
	self workingCopy
		removeMapper: mapper;
		addMapper: (mapper class package: (MCPackage named: newString) path: mapper path).
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/9/2026 14:36'
}
SRGRepoGenerator >> renameProjectTo: aString [
	self workingCopy name: aString.
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 21:43'
}
SRGRepoGenerator >> requestSemsterGitLabGroup [
	^ self gitLab requestGroup: 'Semester group:'
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/13/2026 15:39'
}
SRGRepoGenerator >> reset [
	self acceptChangesDialogDuring: [(self workingCopy ifNil: [^ self]) operationStarter actionResetToCommitAndRestoreIt: self initialHeadCommit].
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/13/2026 15:41'
}
SRGRepoGenerator >> runForSwa [
	self
		dryRunFromUser;
		studentsFromRequestedFile;
		selectWorkingCopy;
		gitLabTokenFromUser;
		selectSemesterGitLabGroup;
		addTutorsToSemesterGitLabGroup;
		handleStudentGroupsForSwa;
		reset;
		showLogs.
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/11/2026 21:44'
}
SRGRepoGenerator >> selectSemesterGitLabGroup [
	self semesterGitLabGroup: self requestSemsterGitLabGroup.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/21/2026 12:21'
}
SRGRepoGenerator >> selectTutors [
	| potentialTutors |
	potentialTutors := ((self students ifNil: [^ nil])
		select: [:each | each groupNumber isNil and: [each isAtHPI]])
		sorted: #printString ascending.
	^ Project uiManager
		chooseMultipleFrom: potentialTutors
		values: potentialTutors
		title: 'Select tutors:'
]

{
	#category : #repository,
	#'squeak_changestamp' : 'mad 10/21/2026 13:49'
}
SRGRepoGenerator >> selectWorkingCopy [
	| names workingCopyName |
	names := GSGitWorkingCopy registeredNames sorted.
	workingCopyName := Project uiManager
		chooseFrom: (names copyWith: 'Clone new')
		values: (names copyWith: #clone)
		title: 'Template repository:'.
	workingCopyName ifNil: [^ self].
	self workingCopy:
		(workingCopyName = #clone
			ifTrue: [GSGitWorkingCopy cloneFromUserAndRegister]
			ifFalse: [GSGitWorkingCopy named: workingCopyName]).
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:44'
}
SRGRepoGenerator >> semesterGitLabGroup [
	^ semesterGitLabGroup
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/11/2026 21:44'
}
SRGRepoGenerator >> semesterGitLabGroup: aGitLabGroup [
	semesterGitLabGroup := aGitLabGroup
]

{
	#category : #running,
	#'squeak_changestamp' : 'mad 10/13/2026 15:41'
}
SRGRepoGenerator >> showLogs [
	self inform: ((#('Logs from the run:'), (self log collect: [:each | '* ', each]))
					joinSeparatedBy: String cr).
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/10/2026 20:19'
}
SRGRepoGenerator >> studentGroups [
	^ ((self students groupBy: #groupNumber)
		associationsSelect: [:each | each key notNil])
		values collect: [:each | SRGStudentGroup students: each in: self]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 14:52'
}
SRGRepoGenerator >> students [
	^ students
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 14:52'
}
SRGRepoGenerator >> students: aCollection [
	students := aCollection
]

{
	#category : #moodle,
	#'squeak_changestamp' : 'mad 10/13/2026 15:38'
}
SRGRepoGenerator >> studentsFromRequestedFile [
	self students: self parseMoodleGroupsFromRequestedFile.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 14:05'
}
SRGRepoGenerator >> workingCopy [
	^ workingCopy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'mad 10/9/2026 18:38'
}
SRGRepoGenerator >> workingCopy: aGSGitWorkingCopy [
	workingCopy := aGSGitWorkingCopy.
	self initialHeadCommit: self workingCopy operationStarter headCommit.
]
