<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>

<%@ page import="java.io.ByteArrayOutputStream, java.io.OutputStream"%>
<%@ page import="com.aspose.barcode.generation.*, com.aspose.barcode.*"%>

<% 
try  {
String clientStr =  request.getParameter("idstr");
String caption =  request.getParameter("caption");
int mode =  Integer.parseInt(request.getParameter("mode"));
if(caption == null) caption="";
ByteArrayOutputStream out1 = new ByteArrayOutputStream();
response.setContentType("image/png");
BarCodeGenerator generator = new BarCodeGenerator(EncodeTypes.QR);
generator.getQR().setErrorLevel(QRErrorLevel.LevelL);
//


generator.setAutoSizeMode(AutoSizeMode.Nearest);
generator.getBarCodeWidth().setInches(2.8f);
generator.getBarCodeHeight().setInches(2.8f);

generator.getCaptionAbove().setVisible(true);
        generator.getCaptionAbove().setText(caption);
		generator.getCaptionAbove().setAlignment(StringAlignment.CENTER);

generator.setCodeText(clientStr);
//generator.save("code128.png");
generator.save(out1, 3);

License license = new License();

license.setLicense("E:\\ajp\\apache-tomcat-8.0.15\\webapps\\auth\\Aspose.BarCode.lic");

/*
//for(int i=1;i<200;i++) {
//	String s="";
//	for(int j=0;j<i;j++) s=s+'s';
	int v = 1;
while(true) {
	try {
		
		//generator.setCodeText(s);
		//generator.getQR().setEncodeMode(QREncodeMode.Auto);
		generator.getQR().setEncodeMode(mode);
		generator.getQR().setVersion(v);
		generator.getCaptionAbove().setText(caption+" version: "+v+"("+(4*v+17)+")");
		generator.save(out1, 3);
		//System.out.print("version: "+v+" "+i+"\t");
		break;
	}catch(Exception e) { v++;}
	
}
//}
*/
//System.out.println(generator.getQR().getVersion());


response.setContentLength(out1.size());
OutputStream os = response.getOutputStream();
os.write(out1.toByteArray());

os.flush();
os.close();
}catch(Exception e) {System.out.println(e);}
%>
