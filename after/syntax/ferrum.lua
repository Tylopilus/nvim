-- Ferrum syntax highlighting (regex-based, since no treesitter grammar exists yet)

vim.cmd([=[
    syntax clear

    " Keywords
    syntax keyword ferrumKeyword fn let mut if else match while for loop return break continue in move ref impl trait struct enum use mod pub self Self const static unsafe where type dyn as crate super
    syntax keyword ferrumType i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 bool char str String Vec Option Result
    syntax keyword ferrumBoolean true false
    syntax keyword ferrumMacro panic println print assert
    highlight default link ferrumKeyword Keyword
    highlight default link ferrumType Type
    highlight default link ferrumBoolean Boolean
    highlight default link ferrumMacro Macro

    " Comments
    syntax match ferrumComment "//.*$"
    highlight default link ferrumComment Comment

    " Strings
    syntax region ferrumString start=/"/ skip=/\\"/ end=/"/
    highlight default link ferrumString String

    " Characters
    syntax region ferrumCharacter start=/'/ skip=/\\'/ end=/'/
    highlight default link ferrumCharacter Character

    " Numbers
    syntax match ferrumNumber "\<\d\+\>"
    syntax match ferrumNumber "\<0x[0-9a-fA-F]\+\>"
    syntax match ferrumNumber "\<0o[0-7]\+\>"
    syntax match ferrumNumber "\<0b[01]\+\>"
    syntax match ferrumFloat "\<\d\+\.\d\+\>"
    highlight default link ferrumNumber Number
    highlight default link ferrumFloat Float

    " Lifetime parameters
    syntax match ferrumLifetime "'[a-zA-Z_][a-zA-Z0-9_]*"
    highlight default link ferrumLifetime StorageClass

    " Operators
    syntax match ferrumOperator "[-+*/%&|<>!=]"
    syntax match ferrumOperator "&&"
    syntax match ferrumOperator "||"
    syntax match ferrumOperator "=="
    syntax match ferrumOperator "!="
    syntax match ferrumOperator "<="
    syntax match ferrumOperator ">="
    syntax match ferrumOperator "->"
    syntax match ferrumOperator "=>"
    syntax match ferrumOperator "::"
    syntax match ferrumOperator "\*\*"
    syntax match ferrumOperator "<<"
    syntax match ferrumOperator ">>"
    highlight default link ferrumOperator Operator

    " Functions
    syntax match ferrumFunction "\<\l[[:alnum:]_]*\>\s*("me=e-1
    highlight default link ferrumFunction Function

    " Attributes / decorators
    syntax match ferrumAttribute "#\[[^\]]*\]"
    highlight default link ferrumAttribute PreProc

    " Brackets and delimiters
    syntax match ferrumDelimiter "[{}\[\]()]"
    highlight default link ferrumDelimiter Delimiter

    " Mutable reference marker
    syntax match ferrumMutable "\&mut\>"
    highlight default link ferrumMutable Keyword

    let b:current_syntax = "ferrum"
]=])
