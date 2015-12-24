function infolayout (i){
	switch(i)
	 {
    case '1':
        
		$('#info1').addClass('infohover');
		$('#info2').removeClass('infohover');
		$('#info3').removeClass('infohover');
        break;
    case '2':
        
		$('#info1').removeClass('infohover');
		$('#info2').addClass('infohover');
		$('#info3').removeClass('infohover');
        break;
    default:
        
		$('#info1').removeClass('infohover');
		$('#info2').removeClass('infohover');
		$('#info3').addClass('infohover');
	} 
    } 

function getval(sel) {
       alert(sel.value);
    }