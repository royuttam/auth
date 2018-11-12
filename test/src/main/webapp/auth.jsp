<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>

<%@ page import="java.util.*, java.io.* "%>
<%@ page import="java.io.ByteArrayOutputStream, java.io.OutputStream"%>
<%@ page import="qr.*, java.util.Date"%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="instascan.min.js"></script>
</head>
<body>

<%! 
public ClientInfo load(String login, String root) throws Exception {
	Properties prop = new Properties();
	prop.load(new FileInputStream(root+"system.conf"));
	String s = prop.getProperty(login);	
	String[] str = s.split("\\.");
	String[] mstr = str[5].split(" ");
	int[] m = new int[mstr.length];
	for(int i=0;i<mstr.length;i++) m[i]=Integer.parseInt(mstr[i]);
	
	ClientInfo info = new ClientInfo(str[1],str[4].split(" "), m);		
	info.ss = str[2]; info.cs = Integer.parseInt(str[3]);	
	return info;	
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
%>
<% 
String login =  request.getParameter("login");
String passwd =  request.getParameter("passwd");
int cc =  Integer.parseInt(request.getParameter("cc"));
out.println("login = "+login+"<br/>");

String root = request.getServletContext().getRealPath("/")+"/";
ClientInfo info = load(login, root);

if(info != null) {	
	
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
		
		//for(String hash: info.h)
		//out.print(hash+" ");
		//out.println("<br/>");
		
		String OTP = Utils.generateOTP(challenge,st,info.h);
		out.println("initial seed st = "+st+"<br>"+OTP);
		
		//String seed = "SkJ6L8a9Xas6jjx6Icvk3vVHjZXUqsg3c2B9dDucAhRzuVkUWql!zta5pVnoy1xzfzQ5$nSDHeiC$kmIhLvXuc";
		//String OTP1 = Utils.generateOTP(new int[] {0},seed,new String[] {"MD2"});
		//out.println("initial seed seed = "+seed+"<br>"+OTP1);
		
	
	
	%>
	<!--
	<img src="QR.jsp?idstr=<%= path %>&mode=0&caption=Challenge(<%=challenge.length%>)">
	
	<img src="QR.jsp?idstr=<%= OTP %>&mode=1&caption=OTP"><br/>
	-->
	<img src="QR1.jsp?idstr=<%= path %>&mode=0&caption=Challenge">
	<img src="QR1.jsp?idstr=<%= OTP %>&mode=1&caption=OTP"><br />
	
	<!--
	<img src="servlet/GenerateQRCode?qrText=<%= path %>">
	<img src="servlet/GenerateQRCode?qrText=<%= OTP %>">
	-->
	<form method="POST" action="check.jsp">
	<label for="otp"> OTP: </label> 
	<input id="otp" type="text" name="otp" size="30" />
	<input id="login" type="hidden" name="login" value="<%=login%>" />
	<input id="cc" type="hidden" name="cc" value="<%=cc%>" />
	<a href="javascript:startCamera()">Read from QR</a><br/>
	<input id="validate" type="submit" value="Validate" />
	
	</form>
	<%
}	
%>
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
	
   //startCamera();

    </script>
</body>
</html>