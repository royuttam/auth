package qr;
public class ClientInfo {
		public String si, ss;
		public int cs;
		public String[] h;
		public int[] m;
		public ClientInfo(String si, String[] h, int[] m) {
			this.si = si;
			this.h = h;
			this.m = m;
			cs = 0;
			ss = si;
		}
	}