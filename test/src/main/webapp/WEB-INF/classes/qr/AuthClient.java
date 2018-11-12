package qr;
import java.net.*;
import javax.net.*;
import javax.net.ssl.*;
import java.io.*;
import java.util.List;
import java.util.Properties;

public class AuthClient {
	BufferedReader br;
	String si;
	String[] h;
	String cs;
	int cc;
	String hs;
	//--------------------------------------------------------------------------------	
	public AuthClient() {
		try {			
			while(true) {
				br = new BufferedReader(new InputStreamReader(System.in));
				System.out.print("$: ");
				String cmd = br.readLine();
				if(cmd.equals("r")) register();
				else if(cmd.equals("a")) auth();
				else if(cmd.equals("l")) load();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	//--------------------------------------------------------------------------------	
	public void load() throws Exception {
		Properties prop = new Properties();
		prop.load(new FileInputStream("system.conf"));
		si = prop.getProperty("si");
		cs = prop.getProperty("cs");
		cc = Integer.parseInt(prop.getProperty("cc"));
		hs = prop.getProperty("hs");
		h = hs.split(" ");
		System.out.print("si = "+si+"\ncs = "+cs+"\ncc = "+cc+"\nh = ");
		for(String hash: h)
		System.out.print(hash+" ");
		System.out.println();
	}
	//--------------------------------------------------------------------------------		
	public void save() throws Exception {
		Properties prop1 = new Properties();
		OutputStream output = new FileOutputStream("system.conf");
		prop1.setProperty("si", si);
		prop1.setProperty("cs", cs);
		prop1.setProperty("cc", cc+"");
		prop1.setProperty("hs", hs+"");
		prop1.store(output, null);
	}
	//--------------------------------------------------------------------------------	
	public void auth() throws Exception {
		load();			
		//cs = si;
		//for(int i=0;i<cc;i++) {
		//cs=Utils.updateSeed(cs,h[0]);
		//}
		
		System.out.print("challenge = ");
		String[] items = br.readLine().split(" ");
		int[] challenge = new int[items.length];

		for (int i = 0; i < items.length; i++) {
			try {
				challenge[i] = Integer.parseInt(items[i]);
				//System.out.print(challenge[i]+" ");
			} catch (NumberFormatException nfe) {
				//NOTE: write something here if you need to recover from formatting errors
			};
		}
		
		String OTP = Utils.generateOTP(challenge,cs,h);
		System.out.println("OTP = "+OTP);
		
		cs=Utils.updateSeed(cs,h[0]);
		cc++;
		
		save();		
	}
	
	//--------------------------------------------------------------------------------	
	public void register() throws Exception {
		try {		
			System.out.print("si: ");
			si = br.readLine();
			System.out.print("h: ");
			hs = br.readLine();
			h = hs.split(" ");
			cs = si;
			cc = 0;	
			System.out.println("si = "+si);			
			save();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public static void main(String[] args) {
		new AuthClient();
	}
}
