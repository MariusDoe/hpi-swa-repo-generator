Class {
	#name : #BaselinOfSWARepoGenerator,
	#superclass : #BaselineOf,
	#category : #BaselineOfSWARepoGenerator
}

{
	#category : #baseline,
	#'squeak_changestamp' : 'mad 10/13/2026 15:21'
}
BaselinOfSWARepoGenerator >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'GitS' with: [spec repository: 'github://hpi-swa/git-s:main/src'];
			package: 'SWARepoGenerator' with: [spec requires: #('GitS')];
			group: 'default' with: #('SWARepoGenerator')].
]
