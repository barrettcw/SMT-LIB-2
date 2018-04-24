;;
;; DRAFT 1.0
;;
(theory Strings

 :smt-lib-version 2.6
 :written_by "Cesare Tinelli, Clark Barret, and Pascal Fontaine"
 :date "2018-04-20"
 
 :notes
 "This a theory of character strings and regular expressions over an alphabet 
  consisting of Unicode characters. It is not meant to be used in isolation but 
  in combination with Ints, the theory of integer numbers.
 "
 
;-------
; Sorts
;-------

 :sorts (
  (Char 0)   ; character sort 
  (String 0) ; string sort
  (RegLan 0) ; regular expression sort
  (Int 0)    ; integer sort
)

;-----------
; Constants
;-----------

 ; Character constants
 :funs_description 
 "All indexed identifiers, all of sort Char, of the form 

    (_ char ⟨H⟩) 
   
  where ⟨H⟩ is an SMT-LIB hexadecimal generated by the following BNF grammar

      ⟨H⟩ ::= #x⟨F⟩ | #x⟨F⟩⟨F⟩ | #x⟨F⟩⟨F⟩⟨F⟩ | #x⟨F⟩⟨F⟩⟨F⟩⟨F⟩ | #x⟨2⟩⟨F⟩⟨F⟩⟨F⟩⟨F⟩
      ⟨2⟩ ::= 0 | 1 | 2 
      ⟨F⟩ ::= ⟨2⟩ | 3 | 4 | 5 | 6 | 7 | 8 | 9
            | a | b | b | d | e | f
            | A | B | C | D | E | F 

   Ex:  (_ char #xA)  (_ char #x4E)  (_ char #x123)  (_ char #x1BC3D)  
  
   Each identifier (_ char n), called a _Unicode constant_ in this theory, 
   denotes the Unicode character with code point n – more formally, it denotes 
   the codepoint itself. 
   For instance, 
   - (_ char #x2B) denotes code point 0x0002B, for the character + (PLUS SIGN); 
   - (_ char #x27E8) denotes code point 0x027E8, for ⟨ 
     (MATHEMATICAL LEFT ANGLE BRACKET).
 "

 :notes
 "The use of hexadecimal as indices of indexed symbols requires a (minor)
  extension of the SMT-LIB 2 standard which currently allows only numeral and
  symbols as indices.
 "

 :notes
 "Because of beginning zeros, the same code point is denoted by more than one
  constant. 
  Example: (_ char #x2B), (_ char #x02B), (_ char #x002B) and (_ char #x0002B).
 "

 :notes 
 "The constants represent all the Unicode code points in Planes 0 to 2 of
  Unicode, ranging from 0x00000 to 0x2FFFF. (Planes 3-13 are currently 
  unassigned and 14-16 are special purpose or private planes.)

  References: 
  - https://www.unicode.org/
  - http://www.utf8-chartable.de/
 "

 :notes 
 "Rationale for having a character sort in the theory:
  For some applications it is more convenient to reason about individual
  characters, as opposed to strings of length 1.
 "

 :notes 
 "Rationale for the chosen notation for character constants:
  Because of their large range, Unicode code oints are typically given in
  hexadecimal notation. Using an hexadecimal directly to denote the corresponding 
  character, however, would create an overloading problem in logics that combine 
  this theory with that of bitvectors since hexadecimals denote bitvectors there.
  Using them as indices instead avoids this problem.
 "

 ; String literals (string constants)
 :funs_description 
  "All double-quote-delimited string literals consisting of printable US ASCII 
   characters, those with Unicode code point from 0x00020 to 0x0007E.
   We refer to these literals as _string constants_.
  "

 :notes
  "The restriction to US ASCII characters in string constants is for simplicity
   since that set is universally supported. Arbitrary Unicode characters can be 
   represented with _escape sequences_ which can have one of the following forms: 
       \ud₃d₂d₁d₀  
       \u{d₀} 
       \u{d₁d₀}
       \u{d₂d₁d₀}
       \u{d₃d₂d₁d₀}
       \u{d₄d₃d₂d₁d₀}
   where each dᵢ is a hexadecimal digit and d₄ is restricted to the range 0-2.
   These are the **only escape sequences** in this theory. See later.
  "

 :notes
  "SMT-LIB 2.6 has one escape sequence of its own for string literals. Two
   double quotes are used to represent the double-quote character within 
   a string literal (like the one containing this very note). That escape 
   sequence is at the level of the SMT-LIB frontend of a solver, not at the 
   level of this theory. 
  "
 
; we cannot write "abc" in a string field here, we will need to use ""abc""
:notes
  "Because of SMT-LIB's own escaping conventions, string literals will then 
   be written in quadruple quotes, as in ""abc"", in textual fields here.
 " 

 :values 
 "The set of values for Char is the set of all character constants;
  for String it is set of all string literals; for RegLan it is the set 
  of all ground terms of that sort.
 "

 :notes
 "The set of values for Char, String and RegLan could be restricted further, to 
  remove some redundancies. For instances, we could disallow leading zeros in
  character constants and in escape sequences.
  For RegLan, we could insist on some level of normalization for regular
  expressions values. These restrictions are left to future versions.
 "

;----------------
; Core functions
;----------------
;
; All core functions are total (i.e., fully specified by the theory).

 ; String functions

 :funs (
  ; Character to string injection
  (str Char String) 

  ; String concatenation
  (str.++ String String String :left-assoc)
  
  ; String length
  (str.len String Int)

  ; Lexicographic ordering
  (str.< String String Bool :chainable)   
 ) 

 ; Regular expression functions

 :funs (
 ; String to RE injection
  (str.to-re String RegLan) 

  ; RE membership
  (str.in-re String RegLan Bool) 

  ; Constant denoting the empty set of strings
  (re.none RegLan)

  ; Constant denoting the set of all strings 
  (re.all RegLan)

  ; Constant denoting the set of all strings of length 1
  (re.allchar RegLan)

  ; RE concatenation
  (re.++ RegLan RegLan RegLan :left-assoc)

  ; RE union
  (re.union RegLan RegLan RegLan :left-assoc)

  ; RE intersection
  (re.inter RegLan RegLan RegLan :left-assoc)

  ; Kleene Closure
  (re.* RegLan RegLan) 
)

;----------------------------
; Additional functions
;----------------------------
;
; Some functions are partial (i.e., underspecified in the theory).

 :fun (
  ; Reflexive closure of lexicographic ordering
  (str.<= String String Bool :chainable)   
 
  ; Singleton string containing a character at given position 
  ; or empty string when position is out of range.
  ; Total
  (str.at String Int String)

  ; Character at given position in string.
  ; Partial 
  (str.char String Int Char)
  ;
  ; Discussion: Could be made total by mapping input with out-of-range position
  ;             to some agreed upon _error_ character.

  ; Substring
  ; (str.substr s i n) denotes the substring of s of length (up to) n starting 
  ; at position i.
  ; Total
  (str.substr String Int Int String)
  ;
  ; Discussion: consider alternative proposals for output in case of
  ;  - negative index, 
  ;  - (index + offset) greater than length, 
  ;  - negative offset

  ; First string is a prefix of second one.
  ; (str.prefixof s t) is true iff s is a prefix of t.
  ; Total
  (str.prefixof String String Bool)

  ; First string is a suffix of second one.
  ; (str.suffixof s t) is true iff s is a suffix of t.
  ; Total
  (str.suffixof String String Bool)

  ; First string contains second one
  ; (str.contains s t) iff s contains t.
  ; Total
  (str.contains String String Bool)
  
  ; Index of first occurrence of second string in first one.
  ; (str.indexof s t i), with t non-empty and 0 <= i <= |s| is the position 
  ; of the first occurrence of t in s at or after position i, if any. 
  ; Otherwise, it is -1. Note that the result is i whenever i is within range
  ; and t is empty.
  ; Total
  (str.indexof String String Int Int)
  ;
  ; Discussion: alternative behaviors for corner cases could be considered.

  ; Replace 
  ; (str.replace s t t') is the string obtained by replacing the first occurrence 
  ; of t in s, if any, by t'. Note that if t is empty, the result is to prepend
  ; t' to s; also, if t does not occur in s then the result is s.
  ; Total
  (str.replace String String String String)

  ; Digit check
  ; (str.is-digit c) is true iff c is a decimal digit, that is, 
  ; a code point in the range 0x0030 ... 0x0039.
  ; Total
  (str.is-digit Char Bool)

  ; RE Kleene cross
  ; (re.+ e) abbreviates (re.++ e (re.* e)).
  ; Total
  (re.+ RegLan RegLan) 

  ; RE option
  ; (re.opt e) abbreviates (re.union e (str.to-re ""))
  ; Total
  (re.opt RegLan RegLan) 

  ; RE range
  ; (re.range s₁ s₂) is the set of all strings s with (str.<= s₁ s s₂)
  ; Total
  (re.range String String) 

  ; Function symbol indexed by a numeral n.
  ; ((_ re.^ n) e) is the nth power of e:
  ; - ((_ re.^ 0) e) = (str.to-re "") 
  ; - ((_ re.^ n') e) = (re.++ e ((_ re.^ n) e))  where n' = n + 1
  ;
  ((_ re.^ n) RegLan RegLan)

  ; Function symbol indexed by two numerals n₁ and n₂.
  ; - ((_ re.loop n₁ n₂) e) = ((_ re.^ n₁) e)           if n₁ >= n₂
  ; - ((_ re.loop n₁ n₂) e) = 
  ;     (re.union ((_ re.^ n₁) e) ... ((_ re.^ n₂) e))   if n₁ < n₂
  ;
  ((_ re.loop n₁ n₂) RegLan RegLan)
  ;
  ; Discussion: Should ((_ re.loop n₁ n₂) e) be equal to re.none when n₁ > n₂?
 )
  
 :notes
 "The symbol re.^ is indexed, as opposed to having an additional Int argument 
  for n, is problematic because then n can be symbolic in a formula, complicating 
  solving or requiring a logic that restrict n to be a numeral only.
  The same argument applies to re.loop and has been used for functions in other 
  theories, such as (_ extract i j) in FixedSizeBitVectors.
 "

;---------------------------
; Maps to and from integers
;---------------------------

 :fun (
  ; Conversion to integers.
  ; (char.code c) denotes the integer represented by c's code point 
  ; when seen as an integer number in hexadecimal notation.
  ; Total
  (char.code Char Int)

 ; Conversion to integers.
  ; (char.from-int n) denotes the character with code point n
  ; if n is in range.
  ; Partial
  (char.from-int Int Char)
  ;
  ; Discussion: It could be made total by having it return an agreeed upon 
  ; _error_ character when n is out of range.

  ; Conversion to integers.
  ; (str.to-int s) with s consisting of digits (in the sense of str.is-digit)
  ; evaluates to the positive integer denoted by s if seen as number in base 10.
  ; It evaluates to -1 if s is empty or contains non-digits. 
  ; Total
  (str.to-int String Int)
  ;
  ; Discussion:
  ; Should we allow the representation of negative integers – with, e.g.,
  ; (str.to-int "-123") evaluating to -123?
  ; If so, to what should we map the empty string and strings with extraneous
  ; characters?
  
  ; Conversion from integers.
  ; (str.from-int n) with n non-negative is the corresponding string in decimal
  ; notation. Otherwise, it is the empty string. 
  ; Total
  (str.from-int Int String)
  ;
  ; Discussion:
  ; If str.to-int can also accept representations of negative integers
  ; str.from-int should map negative integers to their corresponding string
  ; (so that (str.to-int (str.from-int n)) equals n for all n).
 )


:definition
 "For every expanded signature Σ, the instance of Strings with that signature
  is the theory consisting of all Σ-models that satisfy the constraints detailed
  below.
  We use ⟦ _ ⟧ to denote the meaning of a symbol in a given Σ-model.

  * Char 
 
    ⟦Char⟧ is the set of all integers from 0x00000 to 0x2FFFF, representing the set
    of all code points for Unicode characters in Planes 0-2. 

  * String

    ⟦String⟧ is the set ⟦Char⟧* of all words, in the sense of universal algebra, 
    over the alphabet ⟦Char⟧ of Unicode characters, with juxtaposition denoting
    the concatenation operator here. 

    Note: Character positions in a word are numbered starting at 0.

  * RegLan

    ⟦RegLan⟧ is the powerset of ⟦String⟧, the set of all subsets of ⟦String⟧. 
    Each subset can be seen as a language with alphabet ⟦Char⟧. 
    Each term of sort RegLan denotes a regular language in ⟦RegLan⟧.

  * Int

    ⟦Int⟧ is the set of integer numbers.

  * Char constants

    Each Unicode constant is interpreted as the corresponding code point.
    For example, constant (_ char #x3B1) is interpreted as code point 0x003B1,
    for the letter α.  

  * String constants

    1. The empty string constant """" is interpreted as the empty word ε of ⟦Char⟧*.

    2. Each string constant containing a single (printable) US ASCII character is
       interpreted as the word consisting of the corresponding Unicode character
       code point.
       
       Ex: ⟦""m""⟧ = ⟦(_ char #x6D)⟧ = 0x0006D
           ⟦"" ""⟧ = ⟦(_ char #x20)⟧ = 0x00020

    3. Each string constant of the form ""\ud₃d₂d₁d₀"" where each dᵢ is a
       hexadecimal digit and d₄ is in the set {0,1,2} is interpreted as
       the word consisting of just the character with code point 0xd₃d₂d₁d₀

       Ex: ⟦""\u003A""⟧ = ⟦(_ char #x3A)⟧ = 0x0003A

    4. Each literal of the form ""\u{d₀}"" (resp., ""\u{d₁d₀}"", ""\u{d₂d₁d₀}"",
       ""\u{d₃d₂d₁d₀}"", or ""\u{d₄d₃d₂d₁d₀}"") where each dᵢ is a hexadecimal 
       digit and d₄ is in the set {0,1,2} is interpreted as the word consisting 
       of just the character with code point 0xd₀ (resp., 0xd₁d₀, 0xd₂d₁d₀, 
       0xd₃d₂d₁d₀, or 0xd₄d₃d₂d₁d₀).

       Ex: ⟦""\u{3A}""⟧ = ⟦(_ char #x3A)⟧ = 0x0003A

    5. ⟦l⟧ = ⟦l₁⟧⟦l₂⟧  if l does not start with an escape sequence and can be 
       obtained as the concatenation of a one-character string literal l₁ and
       a non-empty string literal l₂.

       Ex: ⟦""a\u002C1""⟧ = ⟦""a""⟧⟦""\u002C1""⟧ = 0x00061 0x002C1
           ⟦""\u2CA""⟧ = 0x0005C ⟦""u2CXA""⟧           (not an escape sequence)
           ⟦""\u2CXA""⟧ = 0x0005C ⟦""u2CXA""⟧          (not an escape sequence)
           ⟦""\u{ACG}A""⟧ = 0x0005C ⟦""{ACG}A""⟧       (not an escape sequence)

    6. ⟦l⟧ = ⟦l₁⟧⟦l₂⟧  if l can be obtained as the concatenation of string literals
       l₁ and l₂ where l₁ is an escape sequence and l₂ is non-empty.

       Ex: ⟦""\u002C1a""⟧ = ⟦""\u002C""⟧⟦""1a""⟧ = 0x0002C ⟦""1a""⟧
           ⟦""\u{2C}1a""⟧ = ⟦""\u{2C}1a""⟧ = 0x0002C ⟦""1a""⟧

    Note: Character positions in a string literal are numbered starting at 0, 
          with escape sequences treated as a single character – consistently
          with their semantics.

          Ex.: In ""a\u1234T"", character a is at position 0, the character 
               corresponding to ""\u1234"" is at position 1, and character T is
               at position 2.

  * (str Char String) 

    ⟦str⟧  maps each element of ⟦Char⟧ to the word in ⟦Char⟧* consisting of just
    that element.

  * (str.++ String String String) 

    ⟦str.++⟧ is the word concatenation function.

  * (str.len String Int)

    ⟦str.len⟧(w) is the number of characters (elements of ⟦Char⟧) in w,
    denoted below as |w|. 

    Note: ⟦str.len⟧(w) is **not** the number of bytes used by some Unicode
          encoding, such as UTF-8 – that number can be greater than the number 
          of characters. 

    Note: ⟦str.len(""\u1234"")⟧  is 1 since every escape sequence denotes 
          a single character.

  * (str.< String String Bool)

    ⟦str.<⟧(w₁, w₂) is true iff w₁ is smaller than w₂ in the lexicographic 
    extension to ⟦Char⟧* of the standard numerical < ordering over ⟦Char⟧.

  * (str.to-re String RegLan) 

    ⟦str.to-re⟧(w) = { w }.

  * (str.in-re String RegLan Bool) 

    ⟦str.in-re⟧(w, L) = true iff w ∈ L.

  * (re.none RegLan)

    ⟦re.none⟧  = ∅ .

  * (re.all RegLan)

    ⟦re.all⟧  = ⟦String⟧ = ⟦Char⟧* .

  * (re.allchar RegLan)

    ⟦re.allchar⟧  = { w ∈ ⟦Char⟧* | |w| = 1 } .

  * (re.++ RegLan RegLan RegLan :left-assoc)

    ⟦re.++⟧(L₁, L₂) = { w₁w₂ | w₁ ∈ L₁ and w₂ ∈ L₂ }

  * (re.union RegLan RegLan RegLan :left-assoc)

    ⟦re.union⟧(L₁, L₂) = { w | w ∈ L₁ or w ∈ L₂ }

  * (re.inter RegLan RegLan RegLan :left-assoc)

    ⟦re.inter⟧(L₁, L₂) = { w | w ∈ L₁ and w ∈ L₂ }

  * (re.* RegLan RegLan) 

    ⟦re.*⟧(L) is the smallest subset K of ⟦Char⟧* such that
    1. ε ∈ K
    2. ⟦re.++⟧(L,K) ⊆ K

  * (str.<= String String Bool)

    ⟦str.<=⟧(w₁, w₂) is true iff either ⟦str.<⟧(w₁, w₂) or w₁ = w₂.

  * (str.at String Int String)

    ⟦str.at⟧(w, n) = ⟦str.substr⟧(w, n, 1) 

  * (str.char String Int Char)

    ⟦str.char⟧(w, n) is the character at position n in w if 0 <= n < |w|.

    Note: The returned value is (currently) unspecified when n < 0 or |w| <= n.

  * (str.substr String Int Int String)

    ⟦str.substr⟧(w, m, n) is the unique word w₂ such that
    for some words w₁ and w₃
      - w = w₁w₂w₃ 
      - |w₁| = m
      - |w₂| = min(n, |w| - m) 
                                  if 0 <= m < |w| and 0 < n
    ⟦str.substr⟧(w, m, n) = ε      otherwise

    Note: The second part of the definition makes ⟦str.substr⟧ a total function.

  * (str.prefixof String String Bool)

    ⟦str.prefixof⟧(w₁, w) = true  iff  w = w₁w₂ for some word w₂

  * (str.suffixof String String Bool)

    ⟦str.suffixof⟧(w₂, w) = true  iff  w = w₁w₂ for some word w₁

  * (str.contains String String Bool)

    ⟦str.contains⟧(w, w₂) = true  iff  w = w₁w₂w₃ for some words w₁, w₃

  * (str.indexof String String Int Int)

    ⟦str.indexof⟧(w, w₂, i) is the smallest n such that for some words w₁, w₃
      - w = w₁w₂w₃
      - i <= n = |w₁|
    if ⟦str.contains⟧(w, w₂) = true and i >= 0

    ⟦str.indexof⟧(w,w₂,i) = -1  otherwise.

    Note: This function too is total.

  * (str.replace String String String String)

    ⟦str.replace⟧(w, w₁, w₂) is the unique word w' such that 
    for some u₁, u₂
      - w  = u₁w₁u₂
      - w' = u₁w₂u₂
      - |u₁| is minimal
                                  if ⟦str.contains⟧(w, w₁) = true

    ⟦str.replace⟧(w, w₁, w₂) = w   otherwise

  * (str.is-digit Char Bool)

       ⟦str.is-digit⟧(c) = true iff  0x00030 <= c <= 0x00039

  * (re.+ RegLan RegLan) 

    ⟦re.+⟧(L) = ⟦re.++⟧(L, ⟦re.*⟧(L))

  * (re.opt RegLan RegLan) 

    ⟦re.opt⟧(L) = L ∪ { ε }

  * (re.range String String)

    ⟦re.range⟧(w₁, w₂) = { w ∈ ⟦Char⟧* | w₁ <= w <= w₂ }  where <= is ⟦str.<=⟧

  * ((_ re.^ n) RegLan RegLan)

    ⟦(_ re.^ n)⟧(L) = Lⁿ  where Lⁿ is defined inductively on n as follows:
    - L⁰ = { ε } 
    - Lⁿ⁺¹ = ⟦re.++⟧(L, Lⁿ)

  * ((_ re.loop i n) RegLan RegLan)

       ⟦(_ re.loop i n)⟧ (L) = Lⁱ ∪ ... ∪ Lⁿ   if i < n       
       ⟦(_ re.loop i n)⟧ (L) = Lⁱ              if i >= n

  * (char.code Char Int)

    ⟦char.code⟧(c) = c          (⟦Char⟧ is a subset of ⟦Int⟧)

  * (char.from-int Int Char)

    ⟦char.from-int⟧(n) = n     if 0x00000 <= n <= 0x2FFFF

  * (str.to-int String Int)

    ⟦str.to-int⟧(w) = -1 if w = ⟦l⟧  where l is the empty string literal or 
    one containing more than digits, i.e., characters with code point in the
    range 0x00030–0x00039.

    ⟦str.to-int⟧(w) = n if w = ⟦l⟧  where l is a string literal consisting
    of a single digit denoting number n.

    ⟦str.to-int⟧(w) = 10*⟦str.to-int⟧(w₁) + ⟦str.to-int⟧(w₂) if 
    - w = w₁w₂
    - |w₁| > 0
    - |w₂| = 1
    - ⟦str.to-int⟧(w₁) >= 0
    - ⟦str.to-int⟧(w₂) >= 0.
 
    Note: This function is made total by mapping the empty word and words with
          non-digits to -1.

    Note: The function returns a non-negative number also for words that start
          with (characters corresponding to) superflous zeros, such as 
          ⟦""0023""⟧.

  * (str.from-int Int String)

    ⟦str.from-int⟧(n) = w  where w is the shortest word such that 
    ⟦str.to-int⟧(w) = n,  if n >= 0.

    ⟦str.from-int⟧(n) = ε,  if n < 0.

    Note: This function is made total by mapping negative integers
          to the empty word.

    Note: ⟦str.to-int⟧(⟦str.from-int⟧(n)) = n iff n is a non-negative integer.

    Note: ⟦str.from-int⟧(⟦str.to-int⟧(w)) = w iff w consists only of digits and
          has no superfluous zeros.
 "
)
