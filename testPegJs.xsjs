var libPeg = $.import("playground.wpdat.Parsers.pegXsjs","libPeg");
var objectsLib = $.import("sap.hana.xs.dt.base.server","objectsLib");

var oDBConnMain = $.db.getConnection($.db.isolation.SERIALIZABLE);
try{

    // Getting then file with grammar //
    // Very first Example: var strGrammarLocation = "playground/wpdat/Parsers/Grammars/gTest1.pegjs";    
    var strGrammarLocation = "playground/wpdat/Parsers/Grammars/gTest2.pegjs";
    var oSession = $.repo.createInactiveSession(oDBConnMain,"");
    var version;
    var oFileGrammar = objectsLib.getObject(strGrammarLocation,version,oSession);
    // generate the Parser classes
    var oParser             = libPeg.PEG.buildParser(oFileGrammar.cdata );
    var strParserSource     = libPeg.PEG.buildParser( oFileGrammar.cdata, { output : 'source'} );
    // Parse source
    // Very first Example: var str2ParseLocation = "playground/wpdat/Parsers/2BeParsed/testOne.xxl";
    var str2ParseLocation = "playground/wpdat/Parsers/2BeParsed/functionTest2.xxl";    
    var oFile2Parse = objectsLib.getObject(str2ParseLocation,version,oSession);
    var strString2Parse = oFile2Parse.cdata;
    var oParseResult = oParser.parse(strString2Parse);
    // Write the parser source code
    var strInternalName = "tTTParser" ; 
    var strParserPath   = "playground.wpdat.Parsers.parsers"; // Punkte statt Striche !!!
    var oWspConn = $.db.getConnection($.db.isolation.SERIALIZABLE);
    var oCreationResult = objectsLib.writeRepositoryObject(strParserPath,strInternalName, 'xsjslib', strParserSource, true, false, oWspConn);
    oWspConn.commit();    
    oWspConn.close();
    // store result
    throw({
           message : "SUCCESS: DONE! " + oParseResult.strParseResult
           });
}
catch(oError)
{
    oDBConnMain.close();
    throw("Result: " + oError.message);
}