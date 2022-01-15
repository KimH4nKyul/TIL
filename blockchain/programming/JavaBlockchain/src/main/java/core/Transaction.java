package core;

// 코인 거래 정보를 기록한다.
public class Transaction {

    String sender;
    String receiver;

    double amount;

    public Transaction(String sender, String receiver, double amount) {
        this.sender = sender;
        this.receiver = receiver;
        this.amount = amount;
    }

    public String getInfo() {
        return sender + " 이(가) " + receiver + " 에게 " + amount + " 개의 코인을 보냄";
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getReceiver() {
        return receiver;
    }

    public void setReceiver(String receiver) {
        this.receiver = receiver;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }
}
