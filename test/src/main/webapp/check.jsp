<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<%@ page import="qr.*, java.util.Date"%>
<%@ page import="java.io.ByteArrayOutputStream, java.io.OutputStream"%>
<%@ page import="java.util.*, java.io.* "%>



<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

</head>
<body>

<%! 
class Info {
	int[] challenge;
	long time;	
}
public Info load1(String login, String root) throws Exception {
	Properties prop = new Properties();
	prop.load(new FileInputStream(root+"challenge.conf"));
	String s = prop.getProperty(login);	
	String[] str = s.split("\\.");
	String[] mstr = str[0].split(" ");
	long time = Long.parseLong(str[1]);
	int[] challenge = new int[mstr.length];
	for(int i=0;i<mstr.length;i++) challenge[i]=Integer.parseInt(mstr[i]);
	
	Info info = new Info();		
	info.challenge = challenge;
	info.time = time;	
	return info;	
}
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
%>
<% 
String login =  request.getParameter("login");
String otp =  request.getParameter("otp");
int cc =  Integer.parseInt(request.getParameter("cc"));
String root = request.getServletContext().getRealPath("/")+"/";
out.println("login = "+login);
Info inf = load1(login, root);
ClientInfo info = load(login, root);
out.println(inf.time+"<br/>");
for(int i:inf.challenge)
out.println(i+" ");

if((System.currentTimeMillis() - inf.time) > 100000) {
	out.print("Timer expired. Retry again");
}
else 

if(info != null) {
	String si = info.si, ss=info.ss;
	int cs = info.cs;					
	out.println("ss = "+ss+", cs = "+cs+"<br/>");
	
	
	String st = ss; 
	out.println("<br/>"+st+"<br/>");
	if(cc >= cs) {
		for(int i=cs+1;i<=cc;i++) 
		st=Utils.updateSeed(st,info.h[0]);
	}
	else {
		st = si; 
		for(int i=0;i<cc;i++) 
		st=Utils.updateSeed(st,info.h[0]);
	}
	out.println("<br/>"+st+"<br/>");
	
	for(String hash: info.h)
	out.print(hash+" ");
	out.println("<br/>");
	String OTP = Utils.generateOTP(inf.challenge,st,info.h);
	out.println(OTP+"<br/>"+otp);
	if(OTP.equals(otp)) {
		info.ss = st;
		info.cs=cc;
		out.println("Authentication sucessfull");
	}
	else 
	out.println("Authentication Failed");
	
	//save(login, challenge, root);		
}	
%>
</body>
</html>