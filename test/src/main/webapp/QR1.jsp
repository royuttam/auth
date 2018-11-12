<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>

<%@ page import="com.google.zxing.common.*,com.google.zxing.*, com.google.zxing.qrcode.*, com.google.zxing.client.j2se.*"%>
<%@ page import="com.google.zxing.qrcode.decoder.*, com.google.zxing.qrcode.encoder.*"%>
<%@ page import="java.io.*, java.util.*"%>



<% 
try  {
String clientStr =  request.getParameter("idstr");
//String caption =  request.getParameter("caption");
//int mode =  Integer.parseInt(request.getParameter("mode"));
//if(caption == null) caption="";
ByteArrayOutputStream out1 = new ByteArrayOutputStream();
response.setContentType("image/png");
QRCodeWriter qrCodeWriter = new QRCodeWriter();
BitMatrix bitMatrix = qrCodeWriter.encode(clientStr, BarcodeFormat.QR_CODE, 300, 300);
MatrixToImageWriter.writeToStream(bitMatrix, "PNG", out1);

Map hintMap = new HashMap();
hintMap.put(EncodeHintType.CHARACTER_SET, CharacterSetECI.UTF8 );

QRCode code = Encoder.encode(clientStr, ErrorCorrectionLevel.L, hintMap);
System.out.println(code.getVersion().getDimensionForVersion() );
//System.out.println(bitMatrix.getBottomRightOnBit().length  ); 

		
response.setContentLength(out1.size());
OutputStream os = response.getOutputStream();
os.write(out1.toByteArray());

os.flush();
os.close();
}catch(Exception e) {System.out.println(e);}
%>
