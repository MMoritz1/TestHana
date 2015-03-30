/* Grammar for testing */
/* Function Inlining */
/* d030819 Feb 2015 */
{
  var iColumnOccurenceCnt=0;
  var oSteering = {
      "bTableDef"   : false,
      "bFieldDef"   : false,
      "bPart1"      : false,
      "bPart2"      : false,
      "bPart3"      : false,
      "bLenghtDef"  : false,
      "iDepth"      : 0
  };
  var aColumnList = [];
  var oColumnListEntry = {};
}

start
=
  wordlist:rWordlist  {   
                           var oResult = {};
                           oResult.strParseResult = wordlist;
                           oResult.aColumnList = aColumnList;
                           return oResult;
                    }
rWordlist
= 
line:(((word / sp+ / "column" / sp+ / word / sp+ )+ cr)+ endoI)* { 
                return "\n Lines: " + line + " !"  
    }

word=
// Sequence does matter: special pattern before more generic ones, otherwise you never observe a reaction
// on the specific pattern
expr:(  tableBegExp / 
        parenthisesOn / 
        parenthisesOff /
        typeList /
        digits /
        comma /
        tableEndExp / 
        semicolon /
        words ) { 
            var strClean = expr.toString().replace(/,/g, "");
            return ' \n' + 'EXPR \t' + strClean ; 
}

tableBegExp
= term:"TABLE" { 
        oSteering.bTableDef = true;
        return term;
    }

tableEndExp
= term:"LANGUAGE" { 
        oSteering.bTableDef = false;
        return term;
    }

parenthisesOn
= term:"("
{
    oSteering.iDepth++;
    if(oSteering.iDepth === 1){
            oSteering.bFieldDef = true;
            }
    if(oSteering.iDepth === 2){
            oSteering.bLenghtDef = true;
            }
    return term ;
}

parenthisesOff
= term:")"
{
    oSteering.iDepth-- ;
    if (oSteering.iDepth === 1){
                    oSteering.bLenghtDef = false;
                    }
    if (oSteering.iDepth === 0){
           oSteering.bFieldDef = false;
           if(typeof oColumnListEntry.name !== 'undefined' && oColumnListEntry.dataTypeName !== 'undefined' )
           {
               var oColumnListEntryL = {};
               oColumnListEntryL.name               = oColumnListEntry.name;
               oColumnListEntryL.dataTypeName       = oColumnListEntry.dataTypeName;
               if(typeof oColumnListEntry.length !== 'undefined' ) oColumnListEntryL.length = oColumnListEntry.length;
               aColumnList.push(oColumnListEntryL);
               return term + " LastEntry " + oColumnListEntryL.name + " " + oColumnListEntryL.dataTypeName + " " + oColumnListEntryL.length ;
               oColumnListEntry = {};                
            }
            else
            {
                return term;
            };
        }
        else
        {
            return term;
        }
}

typeList
= term: ( "VARCHAR" / "NVARCHAR" / "ALPHANUM" / 
          "SHORTTEXT" / "CHAR" /
          "TINYINT" / "SMALLINT" / "SMALLDECIMAL" /
          "REAL" / "DOUBLE" /
          "DECIMAL" / "BIGINT" / "INTEGER" / "DATE" / "NUMBER" /
          "TIMESTAMP" / "TIME" / "SECONDDATE" / "VARBINARY" / 
          "BLOB" / "CLOB" / "NCLOB" / "TEXT" )
{
    if(oSteering.bFieldDef === true){
        oColumnListEntry.dataTypeName = term;
      };
    return term ;
}

digits
= term:[0-9]
{
    if(oSteering.bFieldDef === true && oSteering.bLenghtDef === true){
      if(typeof oColumnListEntry.length === 'undefined')
      {
            oColumnListEntry.length = term;
      }
      else
      {
            oColumnListEntry.length = oColumnListEntry.length + term;
      }
    }
    return term;
}

comma
= term:","
{
 if(oSteering.bFieldDef === true )
 {
       var oColumnListEntryL = {};
       oColumnListEntryL.name               = oColumnListEntry.name;
       oColumnListEntryL.dataTypeName       = oColumnListEntry.dataTypeName;
       if(typeof oColumnListEntry.length !== 'undefined' ) oColumnListEntryL.length = oColumnListEntry.length;
       aColumnList.push(oColumnListEntryL);
       return term + " Entry " + oColumnListEntryL.name + " " + oColumnListEntryL.dataTypeName + " " + oColumnListEntryL.length ;
       oColumnListEntry.length = '';
       oColumnListEntry = {};
   }
   else
   {
        return term;
   };
}

semicolon
= ";"

words=
term:letters+
{
  if(oSteering.bFieldDef === true)
  {
    oColumnListEntry.name = term.toString().replace(/,/g, "");;
    oColumnListEntry.length = '';
  }
  return "W:" + term + " ";
}
letters=
( [a-zA-Z'".:_=*] / digits )  

cr=
"\n"
sp=
    "\t"
  / "\v"
  / "\f"
  / "\r"
  / "\\"
  / " "
  / "\u00A0"
  / "\uFEFF"
endoI
  =
  "END;"
  / !.