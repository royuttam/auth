<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="robots" content="noindex,nofollow"/>
<title>Generate QR Code using QRGen and ZXing library</title>
<link rel="stylesheet" href="/resources/themes/master.css" type="text/css" />
<link
 href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
 rel="stylesheet" type="text/css" />

<script
 src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.js"
 type="text/javascript"></script>
<script
 src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"
 type="text/javascript"></script>
<script
 src="http://ajax.microsoft.com/ajax/jquery.validate/1.7/jquery.validate.js"
 type="text/javascript"></script> 
<script src="/resources/scripts/mysamplecode.js" type="text/javascript"></script>

<script type="text/javascript" src="instascan.min.js"></script>
<video id="preview"></video>
    <script type="text/javascript">
	function startCamera() {
      let scanner = new Instascan.Scanner({ video: document.getElementById('preview') });
      scanner.addListener('scan', function (content) {
	    //alert(content);
		document.getElementById('otp').value = content;
        alert(content);
      });
      Instascan.Camera.getCameras().then(function (cameras) {
        if (cameras.length > 0) {
          scanner.start(cameras[0]);
        } else {
          alert('No cameras found.');
        }
      }).catch(function (e) {
        alert(e);
      });
	}
	
	
    </script>

<script type="text/javascript">
 $(document).ready(function() {
  
  $("#samplecode").validate({
    rules: {
     qrText: "required"
   }
  });
  
 });       
    </script> 
</head>
<body>
<div id="allContent">


<% 
String qrText =  request.getParameter("qrText");
if(qrText == null){
 qrText = "";
}
%>
<div id="myContent" style="width:50%;">
 <form id="samplecode" name="samplecode" method="POST" >
   <fieldset>
    <legend><b>&nbsp;&nbsp;&nbsp;Authenticaton - Request&nbsp;&nbsp;&nbsp;</b></legend>

    <p>
     <label for="qrText"> Login: </label> 
     <input id="qrText" type="text" name="qrText" size="10" value="<%= qrText %>"/><br />
     <label for="pass"> Password </label> 
     <input id="passwd" type="password" name="passwd" size="10" /><br />
	 <label for="sstatus"> Seed status: </label> 
     <input id="sstatus" type="test" name="text" size="10" />

    </p>
    <input id="generate" type="submit" value="Login" />
   </fieldset>
<%
         if (!qrText.trim().equalsIgnoreCase("")) {
            %>
            <fieldset>
    <legend><b>&nbsp;&nbsp;&nbsp;QR Code Generator - Response&nbsp;&nbsp;&nbsp;</b></legend>
             <img src="servlet/GenerateQRCode?qrText=<%= request.getParameter("qrText") %>"><br />
			 <label for="otp"> OTP: </label> 
     <input id="otp" type="test" name="text" size="10" />
   </fieldset>
   <script>
   //startCamera();
   </script>
       <%
         }
            %>
 </form>
</div> 
 

</div>
</body>
</html>