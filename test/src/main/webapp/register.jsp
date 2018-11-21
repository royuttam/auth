<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<%@ page import="qr.*, java.util.Date"%>
<%@ page import="java.util.*, java.io.* "%>
<%@ page import="java.security.MessageDigest, java.nio.charset.StandardCharsets "%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

</head>
<body>
Use your mobile app to read QR code
<%! 
String[] hashAlgorithms = {"SHA-256", "MD2", "MD5", "SHA-1", "SHA-384", "SHA-512"};
int k=4	, Max = 50, Min = Max/2;		
String[] h = new String[k];
int[] m = new int[k];

public String initialize(String[] hf) {	
	String s = "";
	for(int i=0;i<k;i++) {
		int index = (int)(Math.random() * (hf.length));
		h[i] = new String(hf[index]);
		s += h[i] + " ";
	}	
	
	for(int i=0;i<k;i++) 
	m[i] = Min + (int)(Math.random() * ((Max - Min) + 1));
	return s;
}

public void save(String login, ClientInfo info, String root) throws Exception {
	Properties prop1 = new Properties();
	FileInputStream input = new FileInputStream(root+"system.conf");
	prop1.load(input);
	input.close();
	OutputStream output = new FileOutputStream(root+"system.conf");
	String del = ".", s ="";
	for(String hs:info.h) s = s + hs + " "; 	
	String si="";
	for(int mi:info.m) si = si + mi + " "; 	
	String str = login+del+info.si+del+info.ss+del+info.cs+del+s.trim()+del+si.trim();		
	prop1.setProperty(login, str);
	prop1.store(output, null);		
	output.close();
}
%>
<% 

String login =  request.getParameter("login");
String passwd =  request.getParameter("passwd");
String str =  request.getParameter("idstr");

String[] strs = str.split("\\$");
String clientStr = strs[0];

String hf = "";
for(int i=0;i<hashAlgorithms.length;i++)
if(strs[1].contains(hashAlgorithms[i]))
hf = hf + hashAlgorithms[i] + " ";

if(!hf.equals("")) {
	hf = initialize(hf.split(" "));

	String serverStr = Utils.getMACAddress();
	String si = clientStr+serverStr+new Date();
	//out.println(si);
	si = Utils.updateSeed(si,"SHA-512");
	
	/*
	//out.println(login+" "+passwd+" "+clientStr+" "+serverStr+"<br/> "+si);

	//byte[] digest = {2, 5};
	//out.println(Utils.getHexString(digest));

	MessageDigest md=MessageDigest.getInstance( "SHA-256");
	md.update( si.getBytes( StandardCharsets.UTF_8 ) );
	byte[] digest = md.digest();
	//out.println(digest.length);
	//out.println(si.getBytes( StandardCharsets.UTF_8 ).length);
	//out.println(si);

	//out.println("<br/>");
	StringBuffer sb = new StringBuffer();
	for (byte b:digest){
		//sb.append(String.format("%02x", b));
		sb.append((char)(((b & 0xFF)/2)%58+65 ));
		//sb.append((char)(((b & 0xFF)/2)%10+48 ));
		//sb.append(Integer.toHexString(0xFF & b));
		//out.print((char)(((b & 0xFF)/2)%94+33 ));
	}
	//sb.append('c');
	//out.println(sb.toString());
	char[] chars = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9','!','$'};
	int c = 0, sum=0, cnt = 0;
	String s = ""; 
	for(int i=0;i<digest.length*8;i++) {
		int n = i/8, b = i%8;
		if(c == 6) { 
			//out.print(sum+" ");
			s=s+chars[sum];
			sum = 0;c=0; cnt++; 		
		}
		sum = sum + ((((digest[n] >> b) & 1) ==0? 0 : 1) << (i % 6));
		c++;		
	}
	s=s+chars[sum];
	
	//out.print(sum+"<br/> ");
	//out.print(digest.length+" "+bitset.length()+" "+bitset.length()/6.0+" "+cnt);
	
	String s = new String(digest, "UTF-8");
	String s = new String(digest, "ASCII");
	
	StringBuffer sb1 = new StringBuffer();
	for(String hash: h) {
		sb1.append(hash+" ");
	}
	
	String strArray[] = sb1.toString().split(" ");
	*/
	
	out.println("<br/>Initial seed: "+si+" "+si.length()+"<br/>");
	out.println("Hash functions: "+hf+"<br/>");
	ClientInfo info  = new ClientInfo(si.toString(), h,m);
	si=si+"$"+hf;
	//out.println("<br/> QR text length: "+si.length()+"<br/>");
	//}
	String root = request.getServletContext().getRealPath("/")+"/";
	save(login, info, root);
	%>
	<!--
	<img src="QR.jsp?idstr=<%= si %>&mode=1&caption=Initial Seed and hash(<%=si.length()%>)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	-->
	<img src="QR1.jsp?idstr=<%= si %>&mode=1&caption=Initial Seed">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--
	<img src="QR.jsp?idstr=<%= hf %>&caption=Hash functions"><br />
	
	<img src="servlet/GenerateQRCode?qrText=<%= si %>"><br />
	-->
	<%
}
else out.print("Found no common hash functions");
%>
<a href="auth.html">Login</a>
</body>
</html>

