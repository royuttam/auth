package qr;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;
import java.util.Random;
//import java.util.BitSet;

import java.net.InetAddress;
import java.net.NetworkInterface;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;

public class Utils {
	static long N = 0;
	static List<int[]> allPaths = new ArrayList<>();
	//-----------------------------------------------------------------------		
	public static String getMACAddress() {
		try {
			InetAddress ip = InetAddress.getLocalHost();
			NetworkInterface network = NetworkInterface.getByInetAddress(ip);			
			byte[] mac = network.getHardwareAddress();
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < mac.length; i++) {
				sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));		
			}
			return sb.toString();
		}catch(Exception e) {e.printStackTrace();return "";}
	}
	//-----------------------------------------------------------------------		
	public static int[] randomPoint(int[] m) {
		int[] point = new int[m.length];
		//long start = System.currentTimeMillis();
		for(int i = 0; i < m.length; i++) {
			point[i] = 1+(int)(Math.random() * m[i]);
		}
		return point;
	}
	//-----------------------------------------------------------------------		
	public static int[] challenge(int[] m) {	
		int n=0, sz = 0;
		for(int i = 0; i < m.length; i++) 
		sz+=m[i];	
		int[] point = randomPoint(m);
		int[] arr = new int[sz];
		for(int i = 0; i < point.length; i++) 
		for(int j=0;j<point[i];j++) arr[n++]=i;			
		int[] newArr = java.util.Arrays.copyOf(arr, n);
		shuffleArray(newArr);		
		return newArr;
	}
	//-----------------------------------------------------------------------		
	// Implementing Fisher–Yates shuffle
	public static void shuffleArray(int[] ar) {
		int index, a;
		for (int i = ar.length - 1; i > 0; i--) {
			index = (int)(Math.random()*(i + 1));
			a = ar[index];
			ar[index] = ar[i];
			ar[i] = a;
		}
	}
	//-----------------------------------------------------------------------		
	public static String generateOTP(int[] challenge, String sc, String[] h)	 {
		try {
			MessageDigest md;
			for(int i=0;i<challenge.length;i++) {
				md = MessageDigest.getInstance( h[challenge[i]] );
				md.update( sc.getBytes( StandardCharsets.UTF_8 ) );
				byte[] digest = md.digest();
				sc = getHexString(digest);
			}
			return sc;
		}
		catch(NoSuchAlgorithmException e) { return "";}
	}	
	//-----------------------------------------------------------------------			
	public static String updateSeed(String sc, String h) {
		try {
			MessageDigest md=MessageDigest.getInstance( h);
			md.update( sc.getBytes( StandardCharsets.UTF_8 ) );
			byte[] digest = md.digest();
			//return getHexString(digest);
			return getAlphaNumericString(digest);
		}
		catch(NoSuchAlgorithmException e) { return "";}
	}
	//-----------------------------------------------------------------------			
	public static String getHexString (byte[] buf) {
		StringBuffer sb = new StringBuffer();
		for (byte b:buf){
			sb.append(String.format("%02x", b));
		}
		return sb.toString();
	}
	//-----------------------------------------------------------------------			
	public static String getAlphaNumericString (byte[] buf) {
		char[] chars = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9','!','$'};
		//BitSet bitset = BitSet.valueOf(buf);
		int c = 0, sum=0, cnt = 0;
		String s = ""; 
		for(int i=0;i<buf.length*8;i++) {
			int n = i/8, b = i%8;
			if(c == 6) { 
				//out.print(sum+" ");
				s=s+chars[sum];
				sum = 0;c=0; cnt++; 		
			}
			//sum = sum + ((bitset.get(i)?1:0 ) <<(i % 6));
			sum = sum + ((((buf[n] >> b) & 1) ==0? 0 : 1) << (i % 6));
			c++;		
		}
		s=s+chars[sum];
		return s;
	}
	// Returns count of possible paths to reach cell at row number m and column
	// number n from the topmost leftmost cell (cell at 1, 1)
	int  numberOfPaths(int m, int n)	{
		// If either given row number is first or given column number is first
		if (m == 1 || n == 1)
		return 1;

		// If diagonal movements are allowed then the last addition
		// is required.
		return  numberOfPaths(m-1, n) + numberOfPaths(m, n-1);
		// + numberOfPaths(m-1,n-1);
	}
	//-----------------------------------------------------------------------		
	public static long findAllPaths(int[] n) {
		MultiForLoop.loop( n, new MultiForLoop.Callback() { 
			public void act(int[] i) { 
				N += Utils.paths(i);
			}
		});
		long sum = N;
		N=0;
		return sum;
	}
	//-----------------------------------------------------------------------		
	public static void  generateTable() {
		for(int i=2;i<=10;i++) {
			long N = Utils.findAllPaths(new int[]{i,i});
			System.out.println(i+" "+i*i+" "+N+" "+String.format("%.5g", 1.0/(i*i))+" "+String.format("%.5g", 1.0/N)+" "+String.format("%.2f",(float)N/(i*i)));
		}
	}
	//-----------------------------------------------------------------------		
	public static void  generateTable1() {
		List<int[]> list = new ArrayList<>();
		int[] best = new int[0];
		
		for(int k=4;k<=20;k+=2) {
			findCombinations(k,list);
			long maxProd = 0, allPaths = 0;
			for(int[] a : list) {
				long prod = 1;
				for(int i=0;i<a.length;i++) {
					//System.out.print(a[i]+" ");
					prod*=a[i];
				}
				//System.out.println(prod + " "+Utils.findAllPaths(a));
				//if(prod > maxProd ) { best = a; maxProd = prod;}
				long ap = Utils.findAllPaths(a);
				if( ap > allPaths ) { best = a; maxProd = prod;allPaths = ap;}
			}
			
			/*System.out.print(k+" "+(k/2)*(k/2)+" ");
			for(int i=0;i<best.length;i++) 
			System.out.print(best[i]+" ");
			System.out.println(maxProd);
			*/
			
			System.out.print(maxProd+"("+best.length+") "+Utils.findAllPaths(new int[]{k/2,k/2})+" "+Utils.findAllPaths(best)+" (k="+best.length+")[");
			for(int i=0;i<best.length;i++) 
			System.out.print(best[i]+",");
			System.out.println("]");
			
			list.clear();
		} 
	}
	//-----------------------------------------------------------------------		
	public static List<int[]> allPaths(int[] n) {
		MultiForLoop.loop( n, new MultiForLoop.Callback() { 
			public void act(int[] i) { 
				allPaths.add(i.clone());
			}
		});
		return allPaths;
	}
	//-----------------------------------------------------------------------		
	public static long paths(int[] arr) {
		long t = 0,b=1;
		for(int i=0;i<arr.length;i++) {
			t=t+arr[i]-1;
			b=b*fact(arr[i]-1);
		}
		return fact(t)/b;
	}
	//-----------------------------------------------------------------------		
	public static void main(String args[]) {		
		System.out.println(Utils.findAllPaths(new int[]{4,4}));
		
		List<int[]> ap = Utils.allPaths(new int[]{4,4});
		Map<String, List<int[]>> map = new HashMap<>();
		Map<String, Long> map1 = new HashMap<>();
		for(int[] p : ap) {
			int sum = 0;
			for(int e : p) {
				sum += e;
				System.out.print(e+" ");
			}
			System.out.println("\t"+Utils.paths(p));
			//System.out.println(p+" "+sum);
			List<int[]> value = map.get(sum+"");
			if(value == null) {
				List<int[]> l = new ArrayList<>();
				l.add(p);
				map.put(sum+"",l);				 
			}
			else 
			value.add(p);		

			Long value1 = map1.get(sum+"");
			if(value1 == null) {
				Long n = new Long(Utils.paths(p));
				map1.put(sum+"",n);				 
			}
			else 
			map1.put(sum+"",new Long(value1+Utils.paths(p)));				 
		}
		
		for (String key : map1.keySet()) {
			System.out.println(key+" "+map1.get(key));
		}
	}

	//-----------------------------------------------------------------------		
	public static void permute(int[] arr){
		permuteHelper(arr, 0);
	}
	//-----------------------------------------------------------------------	
	private static void permuteHelper(int[] arr, int index){
		if(index >= arr.length - 1){ //If we are at the last element - nothing left to permute
			//System.out.println(Arrays.toString(arr));
			//Print the array
			System.out.print("[");
			for(int i = 0; i < arr.length - 1; i++){
				System.out.print(arr[i] + ", ");
			}
			if(arr.length > 0) 
			System.out.print(arr[arr.length - 1]);
			System.out.println("]");
			return;
		}

		for(int i = index; i < arr.length; i++){ //For each index in the sub array arr[index...end]

			//Swap the elements at indices index and i
			int t = arr[index];
			arr[index] = arr[i];
			arr[i] = t;

			//Recurse on the sub array arr[index+1...end]
			permuteHelper(arr, index+1);

			//Swap the elements back
			t = arr[index];
			arr[index] = arr[i];
			arr[i] = t;
		}
	}
	//-----------------------------------------------------------------------		
	public static long fact(long n) {
		long prod = 1;
		for(int i=2;i<=n;i++)
		prod = prod*i;
		return prod;
	}
	//-----------------------------------------------------------------------		
	public static void findCombinationsUtil(int arr[], int index,
	int num, int reducedNum, List<int[]> list)
	{
		// Base condition
		if (reducedNum < 0)
		return;

		// If combination is 
		// found, print it
		if (reducedNum == 0)
		{
			int[] a = new int[index];
			for (int i = 0; i < index; i++) {
				//System.out.print (arr[i] + " ");
				a[i] = arr[i];
			}
			list.add(a);
			//System.out.println();
			return;
		}

		// Find the previous number 
		// stored in arr[]. It helps 
		// in maintaining increasing 
		// order
		int prev = (index == 0) ? 
		1 : arr[index - 1];

		// note loop starts from 
		// previous number i.e. at
		// array location index - 1
		for (int k = prev; k <= num ; k++)
		{
			// next element of
			// array is k
			arr[index] = k;

			// call recursively with
			// reduced number
			findCombinationsUtil(arr, index + 1, num,
			reducedNum - k, list);
		}
	}
	//-----------------------------------------------------------------------	
	/* Function to find out all 
combinations of positive 
numbers that add upto given
number. It uses findCombinationsUtil() */
	public static void findCombinations(int n, List<int[]> list)
	{
		// array to store the combinations
		// It can contain max n elements
		int arr[] = new int [n];		

		// find all combinations
		findCombinationsUtil(arr, 0, n, n, list);
	}
	
}