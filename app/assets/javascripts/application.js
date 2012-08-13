// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.purr
//= require best_in_place
//= require_tree .

$(document).ready( function() {
    $(".dial").knob();
    $('.tips').tooltip('hide');

	
	$("#EntriesTable_btn").click(function() {
		
	});
	

	$.datepicker.setDefaults({
		dateFormat: "D, M d yy"
	});

	$('#startdate').datepicker({ dateFormat: "M d yy"});
	$('#enddate').datepicker({ dateFormat: "M d yy"});
	$('#newentry_caldate').datepicker();
	$('#UserStartDate').datepicker();
	
	$('.best_in_place').best_in_place();	
	
	var $dialog = $('<div id="popup_dialog_box"></div>')
			.html("")
			.dialog({
				autoOpen: false,
				height: 300,
				width: 450,
				modal: true,
				title: 'Add New'
			});
			
	$('a.popup_dialog').click(function() {
					$dialog.dialog('open');
					
				});
	
});