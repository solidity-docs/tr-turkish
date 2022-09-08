/**
 * Solidity, Ethereum platformunda akıllı sözleşmelerin uygulanması için statik olarak yazılan, sözleşme odaklı, yüksek seviyeli bir programlama dilidir.
 */
parser grammar SolidityParser;

options { tokenVocab=SolidityLexer; }

/**
 * Solidity en üst seviyede pragmalara, import direktiflerine ve sözleşmelerin,
 * arayüzlerin, kütüphanelerin, structların, enumların ve constantların tanımlanmasına izin verir.
 */
sourceUnit: (
	pragmaDirective
	| importDirective
	| usingDirective
	| contractDefinition
	| interfaceDefinition
	| libraryDefinition
	| functionDefinition
	| constantVariableDeclaration
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| errorDefinition
)* EOF;

//@doc: inline
pragmaDirective: Pragma PragmaToken+ PragmaSemicolon;

/**
 * İçe aktarma direktifleri farklı dosyalardan tanımlayıcıları içe aktarır.
 */
importDirective:
	Import (
		(path (As unitAlias=identifier)?)
		| (symbolAliases From path)
		| (Mul As unitAlias=identifier From path)
	) Semicolon;
//@doc: inline
//@doc:name aliases
importAliases: symbol=identifier (As alias=identifier)?;
/**
 * İçeri aktarılacak dosyanın yolu.
 */
path: NonEmptyStringLiteral;
/**
 * İçe aktarılacak semboller için takma adların listesi.
 */
symbolAliases: LBrace aliases+=importAliases (Comma aliases+=importAliases)* RBrace;

/**
 * Bir sözleşmenin en üst düzey tanımı.
 */
contractDefinition:
	Abstract? Contract name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Bir arayüzün en üst düzey tanımı.
 */
interfaceDefinition:
	Interface name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Bir kütüphanenin en üst düzey tanımı.
 */
libraryDefinition: Library name=identifier LBrace contractBodyElement* RBrace;

//@doc:inline
inheritanceSpecifierList:
	Is inheritanceSpecifiers+=inheritanceSpecifier
	(Comma inheritanceSpecifiers+=inheritanceSpecifier)*?;
/**
 * Sözleşmeler ve arayüzler için kalıtım belirleyicisi.
 * İsteğe bağlı olarak temel constructor argümanları sağlayabilir.
 */
inheritanceSpecifier: name=identifierPath arguments=callArgumentList?;

/**
 * Sözleşmelerde, arayüzlerde ve kütüphanelerde kullanılabilen tanımlamalar.
 *
 * Arayüzlerin ve kütüphanelerin constructor, arayüzlerin durum değişkenleri ve
 * kütüphanelerin fallback, receive fonksiyonları veya sabit olmayan durum değişkenleri içermeyebileceğini unutmayın.
 */
contractBodyElement:
	constructorDefinition
	| functionDefinition
	| modifierDefinition
	| fallbackFunctionDefinition
	| receiveFunctionDefinition
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| stateVariableDeclaration
	| eventDefinition
	| errorDefinition
	| usingDirective;
//@doc:inline
namedArgument: name=identifier Colon value=expression;
/**
 * Bir fonksiyonu veya benzer bir çağrılabilir nesneyi çağırırken mevcut olan argümanlar.
 * Bağımsız değişkenler ya virgülle ayrılmış liste olarak ya da adlandırılmış bağımsız değişkenlerin haritası olarak verilir.
 */
callArgumentList: LParen ((expression (Comma expression)*)? | LBrace (namedArgument (Comma namedArgument)*)? RBrace) RParen;
/**
 * Nitelikli isim.
 */
identifierPath: identifier (Period identifier)*;

/**
 * Bir modifier'a çağrı yapın. Modifier hiçbir argüman almazsa, argüman listesi
 * tamamen atlanabilir (açılış ve kapanış parantezleri dahil).
 */
modifierInvocation: identifierPath callArgumentList?;
/**
 * Fonksiyonlar ve fonksiyon türleri için görünürlük.
 */
visibility: Internal | External | Private | Public;
/**
 * Fonksiyon argümanları veya dönüş değerleri gibi parametrelerin bir listesi.
 */
parameterList: parameters+=parameterDeclaration (Comma parameters+=parameterDeclaration)*;
//@doc:inline
parameterDeclaration: type=typeName location=dataLocation? name=identifier?;
/**
 * Constructor'ın tanımı:
 * Her zaman bir uygulama sağlamalıdır.
 * Internal veya Public görünürlük belirtmenin kullanımdan kaldırıldığını unutmayın.
 */
constructorDefinition
locals[boolean payableSet = false, boolean visibilitySet = false]
:
	Constructor LParen (arguments=parameterList)? RParen
	(
		modifierInvocation
		| {!$payableSet}? Payable {$payableSet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$visibilitySet}? Public {$visibilitySet = true;}
	)*
	body=block;

/**
 * Fonksiyon tipleri için durum değiştirilebilirliği.
 * Herhangi bir değişebilirlik belirtilmezse varsayılan değişebilirlik 'non-payable' olarak kabul edilir.
 */
stateMutability: Pure | View | Payable;
/**
 * Fonksiyonlar, modifier'lar veya durum değişkenleri için kullanılan bir geçersiz kılma belirteci.
 * Geçersiz kılınan birden fazla temel sözleşmede belirsiz tanımlamalar olduğu durumlarda,
 * temel sözleşmelerin tam bir listesi verilmelidir.
 */
overrideSpecifier: Override (LParen overrides+=identifierPath (Comma overrides+=identifierPath)* RParen)?;
/**
 * Sözleşme, kütüphane ve arayüz fonksiyonlarının tanımı.
 * Fonksiyonun tanımlandığı bağlama bağlı olarak, başka kısıtlamalar da uygulanabilir;
 * örneğin, arayüzlerdeki fonksiyonlar uygulanmamış olmalıdır, yani bir gövde bloğu içermemelidir.
 */
functionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Function (identifier | Fallback | Receive)
	LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Returns LParen returnParameters=parameterList RParen)?
	(Semicolon | body=block);
/**
 * Bir modifier'ın tanımı.
 * Bir modifier'ın gövde bloğu içinde, alt çizginin tanımlayıcı olarak kullanılamayacağını,
 * ancak modifier'ın uygulandığı bir fonksiyonun gövdesi için yer tutucu ifade olarak kullanıldığını unutmayın.
 */
modifierDefinition
locals[
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Modifier name=identifier
	(LParen (arguments=parameterList)? RParen)?
	(
		{!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	(Semicolon | body=block);

/**
 * Özel fallback fonksiyonunun tanımı.
 */
fallbackFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false,
	boolean hasParameters = false
]
:
	kind=Fallback LParen (parameterList { $hasParameters = true; } )? RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	( {$hasParameters}? Returns LParen returnParameters=parameterList RParen | {!$hasParameters}? )
	(Semicolon | body=block);

/**
 * Özel receive fonksiyonunun tanımı.
 */
receiveFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	kind=Receive LParen RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? Payable {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Semicolon | body=block);

/**
 * Bir struct'ın tanımı. Bir kaynak birimin içinde üst seviyede veya bir sözleşme, kütüphane veya arayüz içinde oluşabilir.
 */
structDefinition: Struct name=identifier LBrace members=structMember+ RBrace;
/**
 * Adlandırılmış bir struct üyesinin tanımı.
 */
structMember: type=typeName name=identifier Semicolon;
/**
 * Bir enum tanımı. Bir kaynak birim içinde üst seviyede veya bir sözleşme, kütüphane veya arayüz içinde oluşabilir.
 */
enumDefinition:	Enum name=identifier LBrace enumValues+=identifier (Comma enumValues+=identifier)* RBrace;
/**
 * Kullanıcı tanımlı bir değer türünün tanımı. Bir kaynak birim içinde üst seviyede veya bir sözleşme, kütüphane veya arayüz içinde oluşabilir.
 */
userDefinedValueTypeDefinition:
	Type name=identifier Is elementaryTypeName[true] Semicolon;

/**
 * Bir durum değişkeninin tanımı.
 */
stateVariableDeclaration
locals [boolean constantnessSet = false, boolean visibilitySet = false, boolean overrideSpecifierSet = false]
:
	type=typeName
	(
		{!$visibilitySet}? Public {$visibilitySet = true;}
		| {!$visibilitySet}? Private {$visibilitySet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$constantnessSet}? Constant {$constantnessSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
		| {!$constantnessSet}? Immutable {$constantnessSet = true;}
	)*
	name=identifier
	(Assign initialValue=expression)?
	Semicolon;

/**
 * Sabit bir değişkenin tanımı.
 */
constantVariableDeclaration
:
	type=typeName
	Constant
	name=identifier
	Assign initialValue=expression
	Semicolon;

/**
 * Bir eventin parametresi.
 */
eventParameter: type=typeName Indexed? name=identifier?;
/**
 * Bir event tanımı. Sözleşmelerde, kütüphanelerde veya arayüzlerde meydana gelebilir.
 */
eventDefinition:
	Event name=identifier
	LParen (parameters+=eventParameter (Comma parameters+=eventParameter)*)? RParen
	Anonymous?
	Semicolon;

/**
 * Error parametresi.
 */
errorParameter: type=typeName name=identifier?;
/**
 * Bir error tanımı.
 */
errorDefinition:
	Error name=identifier
	LParen (parameters+=errorParameter (Comma parameters+=errorParameter)*)? RParen
	Semicolon;

/**
 * Kütüphane işlevlerini ve serbest işlevleri türlere bağlamak için yönerge kullanma.
 * Sözleşmeler ve kütüphaneler içinde ve dosya düzeyinde meydana gelebilir.
 */
usingDirective: Using (identifierPath | (LBrace identifierPath (Comma identifierPath)* RBrace)) For (Mul | typeName) Global? Semicolon;
/**
 * Bir türün adı, temel tür,  fonksiyon türü, mapping türü,  kullanıcı tanımlı tür olabilir.
 * (örneğin bir sözleşme veya struct) veya bir dizi türü.
 */
typeName: elementaryTypeName[true] | functionTypeName | mappingType | identifierPath | typeName LBrack expression? RBrack;
elementaryTypeName[boolean allowAddressPayable]: Address | {$allowAddressPayable}? Address Payable | Bool | String | Bytes | SignedIntegerType | UnsignedIntegerType | FixedBytes | Fixed | Ufixed;
functionTypeName
locals [boolean visibilitySet = false, boolean mutabilitySet = false]
:
	Function LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
	)*
	(Returns LParen returnParameters=parameterList RParen)?;

/**
 * Tek bir değişkenin tanımı.
 */
variableDeclaration: type=typeName location=dataLocation? name=identifier;
dataLocation: Memory | Storage | Calldata;

/**
 * Karmaşık bir ifade.
 * Bir dizin erişimi, bir dizin aralığı erişimi, bir üye erişimi, bir fonksiyon
 * çağrısı (isteğe bağlı fonksiyon çağrısı seçenekleriyle), bir tür dönüştürme,
 * bir tekli veya ikili ifade, bir karşılaştırma veya atama, bir üçlü ifade, bir
 * yeni ifade (yani bir sözleşme oluşturma veya bir dinamik bellek dizisinin tahsisi),
 * bir tuple, bir inline dizi veya bir birincil ifade (yani bir tanımlayıcı, literal veya tür adı) olabilir.
 */
expression:
	expression LBrack index=expression? RBrack # IndexAccess
	| expression LBrack start=expression? Colon end=expression? RBrack # IndexRangeAccess
	| expression Period (identifier | Address) # MemberAccess
	| expression LBrace (namedArgument (Comma namedArgument)*)? RBrace # FunctionCallOptions
	| expression callArgumentList # FunctionCall
	| Payable callArgumentList # PayableConversion
	| Type LParen typeName RParen # MetaType
	| (Inc | Dec | Not | BitNot | Delete | Sub) expression # UnaryPrefixOperation
	| expression (Inc | Dec) # UnarySuffixOperation
	|<assoc=right> expression Exp expression # ExpOperation
	| expression (Mul | Div | Mod) expression # MulDivModOperation
	| expression (Add | Sub) expression # AddSubOperation
	| expression (Shl | Sar | Shr) expression # ShiftOperation
	| expression BitAnd expression # BitAndOperation
	| expression BitXor expression # BitXorOperation
	| expression BitOr expression # BitOrOperation
	| expression (LessThan | GreaterThan | LessThanOrEqual | GreaterThanOrEqual) expression # OrderComparison
	| expression (Equal | NotEqual) expression # EqualityComparison
	| expression And expression # AndOperation
	| expression Or expression # OrOperation
	|<assoc=right> expression Conditional expression Colon expression # Conditional
	|<assoc=right> expression assignOp expression # Assignment
	| New typeName # NewExpression
	| tupleExpression # Tuple
	| inlineArrayExpression # InlineArray
 	| (
		identifier
		| literal
		| elementaryTypeName[false]
	  ) # PrimaryExpression
;

//@doc:inline
assignOp: Assign | AssignBitOr | AssignBitXor | AssignBitAnd | AssignShl | AssignSar | AssignShr | AssignAdd | AssignSub | AssignMul | AssignDiv | AssignMod;
tupleExpression: LParen (expression? ( Comma expression?)* ) RParen;
/**
 * Inline dizi ifadesi, içerdiği ifadelerin ortak türünde statik olarak boyutlandırılmış bir diziyi belirtir.
 */
inlineArrayExpression: LBrack (expression ( Comma expression)* ) RBrack;

/**
 * Normal anahtar kelime olmayan Tanımlayıcıların yanı sıra, 'from' ve 'error' gibi bazı anahtar kelimeler de tanımlayıcı olarak kullanılabilir.
 */
identifier: Identifier | From | Error | Revert | Global;

literal: stringLiteral | numberLiteral | booleanLiteral | hexStringLiteral | unicodeStringLiteral;
booleanLiteral: True | False;
/**
 * Tam bir dize literali, bir veya birkaç ardışık alıntılanmış dizeden oluşur.
 */
stringLiteral: (NonEmptyStringLiteral | EmptyStringLiteral)+;
/**
 * Bir veya birkaç ardışık onaltılık dizeden oluşan tam onaltılık dize literali.
 */
hexStringLiteral: HexString+;
/**
 * Bir veya birkaç ardışık unicode string'den oluşan tam bir unicode string literal.
 */
unicodeStringLiteral: UnicodeStringLiteral+;

/**
 * Sayı literalleri isteğe bağlı bir birimle birlikte ondalık veya onaltılık sayılar olabilir.
 */
numberLiteral: (DecimalNumber | HexNumber) NumberUnit?;
/**
 * Kıvrımlı parantezli ifadeler bloğu. Kendi kapsamını açar.
 */
block:
	LBrace ( statement | uncheckedBlock )* RBrace;

uncheckedBlock: Unchecked block;

statement:
	block
	| simpleStatement
	| ifStatement
	| forStatement
	| whileStatement
	| doWhileStatement
	| continueStatement
	| breakStatement
	| tryStatement
	| returnStatement
	| emitStatement
	| revertStatement
	| assemblyStatement
;

//@doc:inline
simpleStatement: variableDeclarationStatement | expressionStatement;
/**
 * İsteğe bağlı olarak "else" kısmı olan if ifadesi.
 */
ifStatement: If LParen expression RParen statement (Else statement)?;
/**
 * İsteğe bağlı init, condition ve post-loop kısmı olan for ifadesi.
 */
forStatement: For LParen (simpleStatement | Semicolon) (expressionStatement | Semicolon) expression? RParen statement;
whileStatement: While LParen expression RParen statement;
doWhileStatement: Do statement While LParen expression RParen Semicolon;
/**
 * Bir devam ifadesi. Yalnızca for, while veya do-while döngüleri içinde izin verilir.
 */
continueStatement: Continue Semicolon;
/**
 * Bir break ifadesi. Yalnızca for, while veya do-while döngüleri içinde izin verilir.
 */
breakStatement: Break Semicolon;
/**
 * Bir try ifadesi. İçerilen ifadenin harici bir işlev çağrısı veya bir sözleşme oluşturma olması gerekir.
 */
tryStatement: Try expression (Returns LParen returnParameters=parameterList RParen)? block catchClause+;
/**
 * Bir try ifadesinin catch cümlesi.
 */
catchClause: Catch (identifier? LParen (arguments=parameterList) RParen)? block;

returnStatement: Return expression? Semicolon;
/**
 * Bir emit ifadesi. İçerilen ifadenin bir event'e referans vermesi gerekir.
 */
emitStatement: Emit expression callArgumentList Semicolon;
/**
 * Bir revert ifadesi. İçerilen ifadenin bir error'e referans vermesi gerekir.
 */
revertStatement: Revert expression callArgumentList Semicolon;
/**
 * Bir inline assembly bloğu.
 * Inline assembly bloğunun içeriği ayrı bir tarayıcı/lexer kullanır, yani bir
 * inline assembly bloğunun içinde anahtar sözcükler ve izin verilen tanımlayıcılar kümesi farklıdır.
 */
assemblyStatement: Assembly AssemblyDialect? assemblyFlags? AssemblyLBrace yulStatement* YulRBrace;

/**
 * Assembly bayrakları.
 * Bayrak olarak çift tırnaklı stringlerin virgülle ayrılmış listesi.
 */
assemblyFlags: AssemblyBlockLParen AssemblyFlagString (AssemblyBlockComma AssemblyFlagString)* AssemblyBlockRParen;

//@doc:inline
variableDeclarationList: variableDeclarations+=variableDeclaration (Comma variableDeclarations+=variableDeclaration)*;
/**
 * Değişken tanımlamalarında kullanılacak bir dizi değişken adı.
 * Boş alanlar içerebilir.
 */
variableDeclarationTuple:
	LParen
		(Comma* variableDeclarations+=variableDeclaration)
		(Comma (variableDeclarations+=variableDeclaration)?)*
	RParen;
/**
 * Bir değişken tanımlama ifadesi.
 * Tek bir değişken başlangıç değeri olmadan tanımlanabilirken, değişken çiftleri
 * yalnızca başlangıç değeriyle tanımlanabilir.
 */
variableDeclarationStatement: ((variableDeclaration (Assign expression)?) | (variableDeclarationTuple Assign expression)) Semicolon;
expressionStatement: expression Semicolon;

mappingType: Mapping LParen key=mappingKeyType DoubleArrow value=typeName RParen;
/**
 * Eşleme anahtarları olarak yalnızca temel tipler veya kullanıcı tanımlı tipler kullanılabilir.
 */
mappingKeyType: elementaryTypeName[false] | identifierPath;

/**
 * Inline assembly bloğu içinde bir Yul ifadesi.
 * continue ve break ifadeleri yalnızca for döngüleri içinde geçerlidir.
 * leave ifadeleri yalnızca fonksiyon gövdeleri içinde geçerlidir.
 */
yulStatement:
	yulBlock
	| yulVariableDeclaration
	| yulAssignment
	| yulFunctionCall
	| yulIfStatement
	| yulForStatement
	| yulSwitchStatement
	| YulLeave
	| YulBreak
	| YulContinue
	| yulFunctionDefinition;

yulBlock: YulLBrace yulStatement* YulRBrace;

/**
 * İsteğe bağlı başlangıç değerine sahip bir veya daha fazla Yul değişkeninin tanımlanması.
 * Birden fazla değişken tanımlanmışsa, yalnızca bir fonksiyon çağrısı geçerli bir başlangıç değeridir.
 */
yulVariableDeclaration:
	(YulLet variables+=YulIdentifier (YulAssign yulExpression)?)
	| (YulLet variables+=YulIdentifier (YulComma variables+=YulIdentifier)* (YulAssign yulFunctionCall)?);

/**
 * Herhangi bir ifade tek bir Yul değişkenine atanabilirken, çoklu atamalar için bir
 * yandan bir fonksiyon çağrısı yapılması gerekir.
 */
yulAssignment: yulPath YulAssign yulExpression | (yulPath (YulComma yulPath)+) YulAssign yulFunctionCall;

yulIfStatement: YulIf cond=yulExpression body=yulBlock;

yulForStatement: YulFor init=yulBlock cond=yulExpression post=yulBlock body=yulBlock;

//@doc:inline
yulSwitchCase: YulCase yulLiteral yulBlock;
/**
 * Bir Yul switch ifadesi yalnızca bir varsayılan durumdan (kullanımdan kaldırılmıştır)
 * veya isteğe bağlı olarak bir varsayılan durum tarafından takip edilen bir veya daha fazla varsayılan olmayan durumdan oluşabilir.
 */
yulSwitchStatement:
	YulSwitch yulExpression
	(
		(yulSwitchCase+ (YulDefault yulBlock)?)
		| (YulDefault yulBlock)
	);

yulFunctionDefinition:
	YulFunction YulIdentifier
	YulLParen (arguments+=YulIdentifier (YulComma arguments+=YulIdentifier)*)? YulRParen
	(YulArrow returnParameters+=YulIdentifier (YulComma returnParameters+=YulIdentifier)*)?
	body=yulBlock;

/**
 * Inline assembly içinde yalnızca noktasız tanımlayıcılar bildirilebilirken,
 * nokta içeren yollar inline assembly bloğunun dışındaki bildirimlere başvurabilir.
 */
yulPath: YulIdentifier (YulPeriod (YulIdentifier | YulEVMBuiltin))*;
/**
 * Dönüş değerlerine sahip bir fonksiyon çağrısı yalnızca bir atama veya değişken bildiriminin
 * sağ tarafı olarak gerçekleşebilir.
 */
yulFunctionCall: (YulIdentifier | YulEVMBuiltin) YulLParen (yulExpression (YulComma yulExpression)*)? YulRParen;
yulBoolean: YulTrue | YulFalse;
yulLiteral: YulDecimalNumber | YulStringLiteral | YulHexNumber | yulBoolean | YulHexStringLiteral;
yulExpression: yulPath | yulFunctionCall | yulLiteral;
