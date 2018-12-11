<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%@ page import="java.util.*, java.io.* "%>
<%@ page import="java.io.ByteArrayOutputStream, java.io.OutputStream"%>
<%@ page import="qr.*, java.util.Date"%>

<%@ page import="java.security.*,java.nio.charset.StandardCharsets"%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script src="./jsQR.js"></script>  
</head>
<body>

<%! 
public ClientInfo load(String login, String root) throws Exception {	
	Properties prop = new Properties();
	prop.load(new FileInputStream(root+"system.conf"));
	String s = prop.getProperty(login);	
	if(s == null) return null;
	else {
		String[] str = s.split("\\.");
		String[] mstr = str[5].split(" ");
		int[] m = new int[mstr.length];
		for(int i=0;i<mstr.length;i++) m[i]=Integer.parseInt(mstr[i]);
		String passwd = str[6];
		ClientInfo info = new ClientInfo(str[1],str[4].split(" "), m, passwd);		
		info.ss = str[2]; info.cs = Integer.parseInt(str[3]);		
		return info;	
	}
}
public void save(String login, int[] challenge, String root) throws Exception {
	Properties prop1 = new Properties();
	FileInputStream input = new FileInputStream(root+"challenge.conf");
	prop1.load(input);
	input.close();
	OutputStream output = new FileOutputStream(root+"challenge.conf");	
	String s="";
	for(int i:challenge) s = s + i + " "; 	
	s=s.trim()+"."+System.currentTimeMillis();
	prop1.setProperty(login, s);
	prop1.store(output, null);		
	output.close();
}
/*
public String encode(String sc, String h) {
		try {
			MessageDigest md=MessageDigest.getInstance( h);
			md.update( sc.getBytes( StandardCharsets.UTF_8 ) );
			byte[] digest = md.digest();
			return getHexString(digest);
			//return getAlphaNumericString(digest);
		}
		catch(NoSuchAlgorithmException e) { return "";}
	}
public String getHexString (byte[] buf) {
		StringBuffer sb = new StringBuffer();
		for (byte b:buf){
			sb.append(String.format("%02x", b));
		}
		return sb.toString();
	}
	*/
%>
<% 
String login =  request.getParameter("login");
String passwd =  request.getParameter("passwd");
int cc =  Integer.parseInt(request.getParameter("cc"));
out.println("login = "+login+"<br/>");

String root = request.getServletContext().getRealPath("/")+"/";
ClientInfo info = load(login, root);

if(info == null) 		
out.println("Login name "+login+" does not exists");
else if(!Utils.updateSeed(passwd,info.h[0]).equals(info.passwd))
out.println("Invalid password");
else {
	String si = info.si, ss=info.ss;
	int cs = info.cs;					
	//out.println("ss = "+ss+", cs = "+cs+"<br/>");		
	
	int[] challenge = Utils.challenge(info.m);
	//	out.println("Your challenge: (length="+challenge.length+")");
	StringBuffer path = new StringBuffer();
	for(int i: challenge) {
		//out.println(i+" ");
		path.append(i);
	}
	save(login, challenge, root);
	out.println("<br/>");
	
	
	String st = ss; 
	//out.println(encode(st,info.h[0])+"<br/>");
	//out.println("<br/>"+st+"<br/>");
	if(cc >= cs) {
		for(int i=cs+1;i<=cc;i++) 
		st=Utils.updateSeed(st,info.h[0]);
		
	}
	else {
		st = si; 
		for(int i=0;i<cc;i++) 
		st=Utils.updateSeed(st,info.h[0]);
	}
	//out.println("<br/>st = "+st+"<br/>");
	
	
	String OTP = Utils.generateOTP(challenge,st,info.h);
	out.println("Initial seed = "+si+"<br/>Counter="+cc+"<br/>Current seed st = "+st+"<br>challenge="+path+"<br>OTP = "+OTP+"<br/>");
	for(String hash: info.h)
	out.print(hash+" ");
	out.println("<br/>");
	
	
	//String seed = "SkJ6L8a9Xas6jjx6Icvk3vVHjZXUqsg3c2B9dDucAhRzuVkUWql!zta5pVnoy1xzfzQ5$nSDHeiC$kmIhLvXuc";
	//String OTP1 = Utils.generateOTP(new int[] {0},seed,new String[] {"MD2"});
	//out.println("initial seed seed = "+seed+"<br>"+OTP1);
	%>
	<!--
	<img src="QR.jsp?idstr=<%= path %>&mode=0&caption=Challenge(<%=challenge.length%>)">
	
	<img src="QR.jsp?idstr=<%= OTP %>&mode=1&caption=OTP"><br/>
	-->
	<img src="QR1.jsp?idstr=<%= path %>&mode=0&caption=Challenge">
	<!--
	<img src="QR1.jsp?idstr=<%= OTP %>&mode=1&caption=OTP"><br />
		
	<img src="servlet/GenerateQRCode?qrText=<%= path %>">
	<img src="servlet/GenerateQRCode?qrText=<%= OTP %>">
	-->
	<form method="POST" action="check.jsp">
	<label for="otp"> OTP: </label> 
	<input id="otp" type="text" name="otp" size="30" />
	<input id="login" type="hidden" name="login" value="<%=login%>" />
	<input id="cc" type="hidden" name="cc" value="<%=cc%>" />
	<a href="javascript:start()">Read from QR</a><br/>
	<input id="validate" type="submit" value="Validate" />
	</form>
	<%
}	
%>

<canvas id="canvas" hidden></canvas>    

<video id="preview"></video>
<script type="text/javascript">
function start() {
	var video = document.createElement("video");
	var canvasElement = document.getElementById("canvas");
	var canvas = canvasElement.getContext("2d");
	//var loadingMessage = document.getElementById("loadingMessage");
	//var outputContainer = document.getElementById("output");
	var outputMessage = document.getElementById("outputMessage");
	//var outputData = document.getElementById("outputData");

	function drawLine(begin, end, color) {
		canvas.beginPath();
		canvas.moveTo(begin.x, begin.y);
		canvas.lineTo(end.x, end.y);
		canvas.lineWidth = 4;
		canvas.strokeStyle = color;
		canvas.stroke();
	}

	// Use facingMode: environment to attemt to get the front camera on phones
	navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function(stream) {
		video.srcObject = stream;
		video.setAttribute("playsinline", true); // required to tell iOS safari we don't want fullscreen
		video.play();
		requestAnimationFrame(tick);
	});

	function tick() {
		//loadingMessage.innerText = "⌛ Loading video..."
		if (video.readyState === video.HAVE_ENOUGH_DATA) {
			//loadingMessage.hidden = true;
			canvasElement.hidden = false;
			//outputContainer.hidden = false;

			canvasElement.height = video.videoHeight;
			canvasElement.width = video.videoWidth;
			canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
			var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
			var code = jsQR(imageData.data, imageData.width, imageData.height, {
inversionAttempts: "dontInvert",
			});
			if (code) {
				drawLine(code.location.topLeftCorner, code.location.topRightCorner, "#FF3B58");
				drawLine(code.location.topRightCorner, code.location.bottomRightCorner, "#FF3B58");
				drawLine(code.location.bottomRightCorner, code.location.bottomLeftCorner, "#FF3B58");
				drawLine(code.location.bottomLeftCorner, code.location.topLeftCorner, "#FF3B58");
				//outputMessage.hidden = true;
				//outputData.parentElement.hidden = false;
				//outputData.innerText = code.data;
				//document.getElementById('idstr').value = code.data;
				document.getElementById('otp').value = code.data;
				alert(code.data);
				
			} else {
				//outputMessage.hidden = false;
				//outputData.parentElement.hidden = true;
			}
		}
		requestAnimationFrame(tick);
	}
}
</script>
</body>
</html>