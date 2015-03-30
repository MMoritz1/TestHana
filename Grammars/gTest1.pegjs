/* Grammar for testing */
/* d030819 Feb 2015 */
{
  var iColumnOccurenceCnt=0;
}

start
=
  wordlist:rWordlist  {   return "\n Top: " + wordlist;   }
  
rWordlist
= 
line:(((word / sp+ / "column" / sp+ / word / sp+ )+ cr)+ endoI)* { 
                return "\n Lines: " + line + " ! \n" 
                + "  " + iColumnOccurenceCnt.toString() + " occurences of column found."; 
    }

word=
expr:letters+ { 
    return ' \n' + expr.toString(); 
}

letters=
[a-zA-Z0-9] 
cr=
"\n"
sp=
" "
endoI=
"#"

