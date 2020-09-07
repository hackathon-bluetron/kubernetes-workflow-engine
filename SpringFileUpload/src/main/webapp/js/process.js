var processedSheetName = "";
function processFile(uploadedFileName) {
	$.ajax({
		cache : false,
		type : "GET",
		data : {"uploadedFileName": uploadedFileName},
		url : "/spring/processFile.ajax"
	}).done(function(fileList) {
		$('#processDiv').html("");
		$('#processDiv').show();
		var dataList = fileList.substr(1, fileList.length - 2);
		var data = dataList.split(",");
		$("#processDiv").append("<ul id='list'></ul>");
		$.each(data, function(index, value) {
			var name=value;
			$("#list").append("<li><a href=\"#\" onclick=\"viewFile('"+name+"');\">" + value + "</a></li>");
		}
		);
	}).fail({

	});
}

function viewFile(result) {
	processedSheetName = result;
	$('#csv-display').html("");
	$.ajax({
		cache : false,
		type : "GET",
		data : {"sheetName": result},
		url : "/spring/viewFile.ajax"
	}).done(function(response) {
		alert(success);
		data = $.csv.toArrays(response);
		generateHtmlTable(data);
		$('#download').show();
	}).fail({

	});
	
	/*$.ajax({
		type: "GET",  
		headers: {'Access-Control-Allow-Origin': 'http://localhost:8080' },
		crossDomain: true,
		url: "http://169.51.204.19:31057/getcsvfile/"+result, //todo
		dataType: "text",       
		success: function(response)  
		{
			data = $.csv.toArrays(response);
			generateHtmlTable(data);
			$('#download').show();
		}   
	});*/
}

function generateHtmlTable(data) {
	var html = '<table  class="table table-condensed table-hover table-striped">';

	if(typeof(data[0]) === 'undefined') {
		return null;
	} else {
		$.each(data, function( index, row ) {
			if(index == 0) {
				html += '<thead>';
				html += '<tr>';
				$.each(row, function( index, colData ) {
					html += '<th>';
					html += colData;
					html += '</th>';
				});
				html += '</tr>';
				html += '</thead>';
				html += '<tbody>';
			} else {
				html += '<tr>';
				$.each(row, function( index, colData ) {
					html += '<td>';
					html += colData;
					html += '</td>';
				});
				html += '</tr>';
			}
		});
		html += '</tbody>';
		html += '</table>';
		$('#csv-display').append(html);
	}
}	

function downloadResult(){
	exportTableToCSV.apply(this, [$('#csv-display>table'), 'gaTable.csv']);
}
function exportTableToCSV($table, filename) {
	var $rows = $table.find('tr:has(td)'),

	tmpColDelim = String.fromCharCode(11),
	tmpRowDelim = String.fromCharCode(0),

	colDelim = ',';
	rowDelim = '\r\n';

	csv = '"' + $rows.map(function (i, row) {
		var $row = $(row);
		$cols = $row.find('td');

		return $cols.map(function (j, col) {
			var $col = $(col),
			text = $col.text();

			return text.replace('"', '""'); 

		}).get().join(tmpColDelim);

	}).get().join(tmpRowDelim)
	.split(tmpRowDelim).join(rowDelim)
	.split(tmpColDelim).join(colDelim) + '"';

	var hiddenElement = document.createElement('a');
	hiddenElement.href = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);
	hiddenElement.target = '_blank';
	hiddenElement.download = processedSheetName;
	hiddenElement.click();
	
	$('#download').hide();
	$('#csv-display').html("");
	
} 
