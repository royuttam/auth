package qr;
public class MultiForLoop {

    public static abstract class Callback {
        public void act(int[] indices){}
    }

    public static void loop(int[] ns, Callback cb) {
        int[] cur = new int[ns.length];
        loop(ns, cb, 0, cur);
    }

    private static void loop(int[] ns, Callback cb, int depth, int[] cur) {
        if(depth==ns.length) {
            cb.act(cur);
            return;
        }

        for(int j = 1; j<=ns[depth] ; ++j ) {
            cur[depth]=j;
            loop(ns,cb, depth+1, cur);
        }
    }
}