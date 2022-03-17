package core;

import java.util.ArrayList;

public class BlockchainStarter {
    // 블록체인이 실질적으로 동작하는 메인 함수
    public static void main(String[] args) {

<<<<<<< HEAD
        // 블록체인 채굴 구현 
        int nonce = 0; // 채굴 난이도, 2의 24제곱이라면 24번 중에 한 번만 채굴에 성공할 수 있다는 것
        // 채굴
        while(true) {
            if(Util.getHash(nonce + "").startsWith("000000")) {
                System.out.println("채굴 성공: " + nonce);
                System.out.println("해시 값: " + Util.getHash(nonce + ""));
=======
//        Block block = new Block(1, 0, "a", "00000000000000000000", transactionList);
//        block.getInfo();
//
//        Block block2 = new Block(2, 0, "b", block.getBlockHash(), transactionList);
//        block2.getInfo();
//
//        Block block3 = new Block(3, 0, "c", block2.getBlockHash(), transactionList);
//        block3.getInfo();
//
//        Block block4 = new Block(4, 0, "d", block3.getBlockHash(), transactionList);
//        block4.getInfo();

        Block b1 = new Block(1, 0, null, new ArrayList<>());
        b1.getInfo();

        Block b2 = new Block(2, 0, b1.getBlockHash(), new ArrayList<>());
        b2.addTransaction(new Transaction("김한결", "우영하", 1.5));
        b2.addTransaction(new Transaction("왕태현", "우영하", 0.5));
        b2.getInfo();

        Block b3 = new Block(3, 0, b2.getBlockHash(), new ArrayList<>());
        b3.addTransaction(new Transaction("우영하", "김한결", 0.2));
        b3.addTransaction(new Transaction("도형우", "왕태현", 0.7));
        b3.getInfo();
>>>>>>> refs/remotes/origin/main

    }
}
