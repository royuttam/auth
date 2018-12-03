package qr;
public class ClientInfo {
		public String si, ss, passwd;
		public int cs;
		public String[] h;
		public int[] m;
		public ClientInfo(String si, String[] h, int[] m, String passwd) {
			this.si = si;
			this.h = h;
			this.m = m;
			this.passwd = passwd;
			cs = 0;
			ss = si;
			
		}
	}