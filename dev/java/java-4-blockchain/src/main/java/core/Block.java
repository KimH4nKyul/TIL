package core;

import util.Util;

import java.util.ArrayList;

public class Block {

    private int blockId;
    private int nonce;
    private String data;
    private String previousBlockHash;
    private ArrayList<Transaction> transactionList;

    public Block(int blockId, int nonce, String previousBlockHash, ArrayList<Transaction> transactionList) {
        this.blockId = blockId;
        this.nonce = nonce;
//        this.data = data;
        this.previousBlockHash = previousBlockHash;
        this.transactionList = transactionList;
    }

    public void addTransaction(Transaction transaction) {
        this.transactionList.add(transaction);
    }

    public String getPreviousBlockHash() {
        return previousBlockHash;
    }

    public void setPreviousBlockHash(String previousBlockHash) {
        this.previousBlockHash = previousBlockHash;
    }

    public int getBlockId() {
        return blockId;
    }

    public void setBlockId(int blockId) {
        this.blockId = blockId;
    }

    public int getNonce() {
        return nonce;
    }

    public void setNonce(int nonce) {
        this.nonce = nonce;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public void getInfo() {
        this.mine();
        System.out.println("-----");
        System.out.println("Block Number: " + this.getBlockId());
        System.out.println("Nonce: " + this.getNonce());
//        System.out.println("Data: " + this.getData());
        System.out.println("Transaction size: " + this.transactionList.size());
        for (Transaction transaction : transactionList) {
            System.out.println(transaction.getInfo());
        }
        System.out.println("Current Block Hash: " + this.getBlockHash());
        System.out.println("Previous Block Hash: " + this.getPreviousBlockHash());
        System.out.println("-----");
    }

    public String getBlockHash() {
        StringBuilder transactionInfo = new StringBuilder();
        for (Transaction transaction : transactionList) {
            transactionInfo.append(transaction.getInfo());
        }
        return Util.getHash(this.nonce + transactionInfo.toString() + this.previousBlockHash);
    }

    private void mine() {
//        // 블록체인 채굴 구현
//        int nonce = 0; // 채굴 난이도, 2의 24제곱이라면 24번 중에 한 번만 채굴에 성공할 수 있다는 것
//        // 채굴
//        while(true) {
//            if(Util.getHash(nonce + "").startsWith("000000")) {
//                System.out.println("채굴 성공: " + nonce);
//                System.out.println("해시 값: " + Util.getHash(nonce + ""));
//
//                break;
//            }
//            nonce++;
//        }
        while(true) {
//            if(this.getBlockHash().substring(0, 4).equals("0000")){
            if(this.getBlockHash().startsWith("0000")){
                System.out.println(this.blockId + " mining success");
                break;
            }
//            if(Util.getHash(this.nonce + this.data + this.previousBlockHash).startsWith("0000")) {
//                System.out.println(this.blockId + " mining success");
//                break;
//            }
            this.nonce++;
        }
    }
}
