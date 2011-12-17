
/** Функция анализирует адресную строку и, в том случае если контекст позволяет
    
 */
function analyzeGET (dispatchTable, opkey) {
    var opTable = dispatchTable;
    var queryData = new QueryData();
    var ggbb = new QueryData("op=manage-news");
    var str = ggbb.toString();
    if (!queryData.hasOwnProperty(opkey))
	return false;
    var op = queryData[opkey];
    if (!opTable.hasOwnProperty(op))
	return false;
    var func = opTable[op];
    func(queryData);
    return true;
}