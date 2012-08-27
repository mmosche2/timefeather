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


	$.datepicker.setDefaults({
		dateFormat: "D, M d yy"
	});

	$('#startdate').datepicker({ dateFormat: "M d yy"});
	$('#enddate').datepicker({ dateFormat: "M d yy"});
	$('#newentry_caldate').datepicker();
	$('#UserStartDate').datepicker();
	$('#StaffingStartDate').datepicker();
	$('#StaffingEndDate').datepicker();
		
	$('.best_in_place').best_in_place();	
	
	var $dialog_project = $('<div id="popup_dialog_box_project"></div>')
			.html("")
			.dialog({
				autoOpen: false,
				height: 300,
				width: 450,
				modal: true,
				title: 'Add New Project'
			});
	var $dialog_employee = $('<div id="popup_dialog_box_employee"></div>')
			.html("")
			.dialog({
				autoOpen: false,
				height: 300,
				width: 450,
				modal: true,
				title: 'Add New Employee'
			});
	var $dialog_staffing = $('<div id="popup_dialog_box_staffing"></div>')
			.html("")
			.dialog({
				autoOpen: false,
				height: 300,
				width: 450,
				modal: true,
				title: 'Add New Staffing'
			});
								
	$('a.popup_dialog_project').click(function() {
		$dialog_project.dialog('open');				
	});
	$('a.popup_dialog_employee').click(function() {
		$dialog_employee.dialog('open');				
	});
	$('a.popup_dialog_staffing').click(function() {
		$dialog_staffing.dialog('open');				
	});
	
	$('.best_in_place').bind("ajax:success", function(xhr, data){
		// highlight effect
		$(this).closest('tr').effect('highlight');
		
		//alert($(this).data('entryHours'));
	});
	
	$('.bip-hours-wrapper .best_in_place').bind("ajax:success", function(xhr, data){
		mydata = JSON.parse(data);
		newhours = mydata.hours;
		hours_sum = mydata.hrs_sum;
		user_id = mydata.user_id;
		user_name = mydata.user_name;
		user_sum = mydata.user_sum;
		project_id = mydata.project_id;
		project_name = mydata.project_name;
		project_sum = mydata.project_sum;
		
		
		$("div#entrytable_sum").html('<p class="totalrow">' + hours_sum + ' hours</p>');
		$('#table_row_hours_sum').html(hours_sum);
		
		$("#filter_employees_"+user_id+"_text").attr('data-original-title', user_sum + ' total hours');
		$("#filter_projects_"+project_id+"_text").attr('data-original-title', project_sum + ' total hours');
	});
	
	// /////////// NOT USED ANYMORE ///////////
	// staffFormButton = $('#StaffEmployeeForm_btn')
	// staffFormButton.click(function(){
	// 	staffFormBox = $('#StaffEmployeeForm');
	// 	if( staffFormBox.is(":hidden")){
	// 		staffFormBox.slideDown("slow");
	// 		staffFormButton.html('Hide Add Staff Box');
	// 	} else {
	// 		staffFormBox.slideUp("slow");
	// 		staffFormButton.html('Add Employee to Project');
	// 	}
	// });
	
});