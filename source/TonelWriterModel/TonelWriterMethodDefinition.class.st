Class {
	#name : 'TonelWriterMethodDefinition',
	#superclass : 'Object',
	#instVars : [
		'category',
		'selector',
		'definitionClass'
	],
	#category : 'TonelWriterModel'
}

{ #category : 'Instance Creation' }
TonelWriterMethodDefinition class >> uniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	^self new initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> allCategories [

	^definitionClass categoriesFor: selector
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> category [

	^category
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> compiledMethod [

	^definitionClass >> selector
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> definitionClass [

	^definitionClass
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> definitionClassName [

	^self definitionClass name
]

{ #category : 'Defaults' }
TonelWriterMethodDefinition >> hasDefaultVACategories [
	"Answer whether receiver should write the categories into aCollection."
	"NOTE:
	 If there is only one category, no need to write #vaCategories key as we are
	 already writing #category:.
	 In the case of extension methods the first in allCategories will be the real one in VA
	 while the one of #category will be one with *X compatible with Tonel/Pharo"

	^self allCategories size = 1 and: [self allCategories first  = self category]
]

{ #category : 'Defaults' }
TonelWriterMethodDefinition >> hasDefaultVAVisibility [

	^self visibilityString = 'public'
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> initializeUniquelyKnownAs: aSymbol in: aClass categorizedAs: aCategory [

	definitionClass := aClass.
	selector := aSymbol.
	category := aCategory
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isPoolPragma [
	"Answer whether receiver compiled method is a declaration of a Pool Dictionary."

	^(EmNamespaceSupport declarationPattern match: selector )
		and: 
				[(self methodBody trimSeparators 
					beginsWithSubCollection: '"%%PRAGMA DECLARE') 
						and: [self methodBody includesSubstring: 'isPool: true']]
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isRealPragma [
		
	^self isVirtual not and: [self isPoolPragma]
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isVirtual [
	"Answer whether receiver wraps an actual compiled method."
	
	^false
]

{ #category : 'testing' }
TonelWriterMethodDefinition >> isVirtualPragma [
		
	^self isVirtual and: [self isPoolPragma]
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> methodBody [

	| parseTree body bodyStream messagePattern |

	parseTree :=
		EsParser
			parse: self compiledMethod sourceString
			class: self compiledMethod methodClass
			scanComments: false
			errorHandler: nil
			ifFail: [nil].

	messagePattern := parseTree messagePattern.
	bodyStream :=
		(self compiledMethod sourceString
			copyFrom: (messagePattern sourceEnd + (CldtConstants::LineDelimiter size) + 1)
			to: parseTree sourceEnd)
				readStream.
				
	body :=
		bodyStream
			skipSeparators;
			contents.
	^body
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> methodDeclaration [

	| parseTree declaration messagePattern |

	parseTree :=
		EsParser
			parse: self compiledMethod sourceString
			class: self compiledMethod methodClass
			scanComments: false
			errorHandler: nil
			ifFail: [nil].
	messagePattern := parseTree messagePattern.
	declaration := messagePattern asString trimBoth: [:char | char isSeparator].
	^declaration
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> pragmaPrefix [
	| pattern |
	pattern := EmNamespaceSupport declarationPattern.
	^pattern copyFrom: 1 to: pattern size - 1.
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
TonelWriterMethodDefinition >> pragmaSuffix [

	^selector copyFrom: (self pragmaPrefix size + 1 min: selector size) to: selector size
]

{ #category : 'Accessing' }
TonelWriterMethodDefinition >> visibilityString [

	^self compiledMethod isPrivate ifTrue: ['private'] ifFalse: ['public']
]
