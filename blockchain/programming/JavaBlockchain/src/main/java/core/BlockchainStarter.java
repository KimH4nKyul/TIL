package core;

import util.Util;

public class BlockchainStarter {
    // 블록체인이 실질적으로 동작하는 메인 함수
    public static void main(String[] args) {

        // 블록체인 채굴 구현 
        int nonce = 0; // 채굴 난이도, 2의 24제곱이라면 24번 중에 한 번만 채굴에 성공할 수 있다는 것
        // 채굴
        while(true) {
            if(Util.getHash(nonce + "").substring(0, 6).equals("000000")) {
                System.out.println("채굴 성공: " + nonce);
                System.out.println("해시 값: " + Util.getHash(nonce + ""));

                break;
            }
            nonce++;
        }
    }
}
