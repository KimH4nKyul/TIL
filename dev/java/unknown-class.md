익명 객체
=========
- 이름이 없는 객체로 생성시 [부모 클래스 | 인터페이스] 타입 이름과 같게 한다.
- 재사용 되지 않고 한 번만 사용되어야 할 경우에 클래스 필드나 로컬 변수의 초기값으로 설정한다.

- 익명 자식 객체
    - 패키지에 존재하는 부모 클래스에 대한 익명 객체 
    ```java
    class AnnonymousClass { 
        
        public void hack() {
            // Do it!
        }
    }
 
    class AnnonymousExam { 
        public static void main(String args[]) [
            
            AnnonymousClass ac = new Annonymous() { // 이렇게 생성된 익명 객체는 AnnonymousClass의 자식 클래스가 된다.
                
                @Override
                public void hack() {                // 익명 자식 객체는 부모 클래스 타입(부모 객체)이기 때문에 부모의 멤버만 사용 가능하고, 
                    // Do it again!                 // 부모의 멤버를 오버라이딩해서만 사용해야 한다.
                }
            };  // 세미 콜론 주의

    }
    ```

- 익명 구현 객체
    - 패키지에 존재하는 인터페이스에 대한 익명 객체
    ```java
    interface AnnonyInterface {
        public abstract void hello();
    }

    class AnnonyInterface {
        public static void main(String args[]) {

            AnnonyInterface ai = new AnnonyInterface() {

                @Override
                public void hello() {
                    System.out.println("안녕하세요!");
                }

            };  // 세미 콜론 주의

        }
    }
    ```

```
created) 2021-05-28
```