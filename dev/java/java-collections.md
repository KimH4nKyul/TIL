1.1. 컬렉션 프레임워크
=====================
- 컬렉션 = 객체의 저장
- 프레임워크 = 사용 방법이 정해져 있는 라이브러리

1.1.1. 주요 인터페이스
---------------------
- List
    - ArrayList
    - Vector
    - LinkedList
- Map 
    - HashMap
    - HashTable
    - TreeMap
    - Properties
- Set
    - HashSet
    - TreeSet

2.1. List 컬렉션
================
- 배열과 비슷하게 객체를 인덱스로 관리한다.
- (차이점) Capacity가 자동으로 증가한다. / 인덱스가 자동으로 부여된다. / 추가, 삭제, 검색을 위한 메소드가 제공된다.
- 객체의 주소를 참조한다. ( ListCollection[0] = 0x12345 -----> 객체 ) 
    - 따라서 중복된 주소를 참조할 수도 있다. 
    - null을 저장해서 객체 참조를 하지 않을 수도 있다.
- 객체 추가
    - add(E e)
        - 객체를 맨 끝에 추가
    - add(int index, E e)
        - 해당 인덱스에 객체 추가
    - set(int index, E e) 
        - 해당 인덱스에 있는 객체를 다른 객체로 바꿈 (쉽게 말해, 값을 대체한다. )
- 객체 검색
    - contains(Object o)
        - 해당 객체가 있는지 검색
    - isEmpty() 
        - 컬렉션이 비어있는지 검색
    - size()    
        - 저장된 전체 객체 수 반환
- 객체 삭제
    - clear()
        - 저장된 전체 객체 삭제
    - remove(int index)
        - 해당 인덱스의 객체 삭제
    - remove(Object o) 
        - 해당 객체를 찾아서 삭제

2.1.1. ArrayList
-----------------
```java
List<E> list = new ArrayList<E>();
```
```java
ArrayList<E> list = new ArrayList<E>();
```
- ArrayList 객체를 생성하면 기본 10개의 객체를 저장할 공간이 생긴다.
- 객체가 늘어날 때 마다 자동으로 공간(용량, Capacity)이 증가한다.
- 객체를 추가 / 삭제 하는 경우가 빈번하다면 LinkedList를 쓰는게 더 좋다.

2.1.2. Vector
--------------
```java
List<E> list = new Vector<E>();
```
- 동기화된(Syncronized) 메소드로 구성되어 있다.
    - 멀티 스레드가 동시에 Vector 메소드를 실행할 수 없고, 하나의 스레드가 메소드 실행을 완료해야 다음 스레드가 메소드를 실행한다.
    - 이를 **Thread-safe** 하다고 한다.

2.1.3. LinkedList
------------------
```java 
List<E> list = new LinkedList<E>();
```
- ArrayList는 내부 배열에 객체를 저장해서 관리한다.
- LinkedList는 인접 참조를 링크해서 **체인**처럼 관리한다.
- 특정 인덱스의 객체를 제거하면 ArrayList처럼 값의 이동이 발생하지 않는다. (ArrayList는 이런 면에서 성능 Down) 
    - **삭제된 객체의 앞뒤 링크만 변경되고 나머지 링크는 그대로** (LinkedList는 이런 면에서 성능 Up)

3.1. Set(*집합*) 컬렉션
======================
- List 컬렉션은 저장 순서를 유지하지만, 
- Set 컬렉션은 저장 순서를 유지하지 않는다. 
- Set 컬렉션은 중복이 허용되지 않는다.
- Set 컬렉션은 하나의 null만 저장할 수 있다.   

- 객체 추가
    - add(E e)
        - 객체 저장, 반환: true or false
- 객체 검색
    - contains(Object o)
        - Object가 컬렉션에 있는지 검사, true or false
    - imEmpty() 
        - 컬렉션이 비어있는지 검사, true or false
    - iterator()
        - 저장된 객체를 한 번씩 가져오는 반복자, Iterator<E>
            ```java
            Set<String> set = ... ;
            Iterator<String> iter = set.iterator();
            ```
            - Set 컬렉션은 인덱스로 객체를 검색할 수 없다.
            - 따라서, 반복자(Iterator)를 사용한다.
            - hasNext()
                - 가져올 객체가 있으면 true, 없으면 false / **next()로 객체를 가져오기 전에 값이 있는지 먼저 확인하는 것이 좋다!**
                ```java
                Set<String> set = ... ;
                Iterator<String> iter = set.iterator();
                while(iter.hasNext()) {
                    String str = iter.next();
                    System.out.println(str);
                }
                ```
                - 좀 더 편한 방법으로는 *향상된 for문*을 사용하는 것이다.
                ```java
                for(String str : set) {
                    System.out.println(str);
                }
                ```
            - next() 
                - 컬렉션에서 하나의 객체를 가져온다. E
            - remove()
                - 컬렉션에서 하나의 객체를 제거한다. void
    - size()
        - 전체 객체 수 검색, int
- 객체 삭제
    - clear()
        - 전체 객체 삭제
    - remove(Object o)
        - Object를 찾아 삭제, true or false

3.1.1. HashSet
---------------
```java
Set<E> set = new HashSet<E>();
```
- HashSet은 객체를 저장하기 전에 먼저 객체의 hashCode() 메소드를 호출해서 해시코드를 얻어내고, 이미 저장되어 있는 객체들의 해시코드와 비교한다.
- 만약 동일한 해시코드가 있다면 equals() 메소드로 두 객체를 비교해서 true가 나오면 동일한 객체로 판단하고 중복 저장을 하지 않는다.
    ```java
    public class Member {
        public String name;
        public int age;

        public Member(String name, int age) {
            this.name = name;
            this.age = age;
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Member) {
                Member mem = (Member) obj;
                return mem.name.equals(name) && (mem.age == age);
            } else {
                return false;
            }
        }

        @Override
        public int hashCode() {
            return name.hashCode() + age;
        }
    }

    public class HashSetExam {
        public static void main(String[] args) {
            Set<Member> set = new HashSet<Memeber>();
            
            set.add(new Member("홍길동", 30));
            set.add(new Member("홍길동", 30));  // 인스턴스는 다르지만 내부 데이터가 동일하므로 객체 1개만 저장

            System.out.println("총 객체수: " + set.size()); // 1
        }
    }
    ```
       
4.1. Map 컬렉션
===============
- Key: Value 로 구성된 Map.Entry 객체를 저장하는 구조
- Entry는 Map 인터페이스 내부에 선언된 중첩 인터페이스
- Key와 Value는 모두 객체
- Key는 중복 안되지만, Value는 중복 가능
- 만일 Key가 중복되면 이전 Key: Value가 새로운 Key: Value로 대체된다.
   
4.1.1. Map 컬렉션 공통 메소드
----------------------------
- 객체 추가
    - V put(K key, V value) 
        - 주어진 key로 value를 저장
        - 새로운 key일 경우 null 반환 
        - 동일한 key일 경우 값을 대체하고 이전 값을 반환
- 객체 검색
    - boolean containsKey(Object key) 
        - key가 있는지 검색
    - boolean containsValue(Object value)
        - value가 있는지 검색
    - Set<Map.Entry<K, V>> entrySet()
        - Key : Value 쌍으로 구성된 모든 Map.Entry 객체를 Set에 담아서 리턴
    - V get(Object key)
        - key에 대한 value를 리턴
    - boolean isEmpty() 
        - Map 컬렉션이 비었는지 검사
    - Set<K> keySet()
        - 모든 키를 Set에 담아서 리턴
    - int size()
        - 저장된 모든 키 개수
    - Collection<V> values() 
        - 모든 값을 Collection에 담아서 리턴
- 객체 삭제
    - void clear()
        - 모든 Map.Entry<K,V> 삭제
    - V remove(Object key)
        - key에 관련한 Map.Entry<K,V>를 삭제하고 value를 리턴

4.2. Map 컬렉션의 사용법
=======================
4.2.1. 기본
-----------
```java
Map<String, integer> map = ... ;
map.put("홍길동", 30);
int score = map.get("홍길동");
map.remove("홍길동");
```

4.2.2. 반복자1
--------------
```java
Map<K, V> map = ... ;
Set<K> keySet = map.keySet();
Iterator<K> iter = keySet.iterator();
while(iter.hasNext()) {
    K key = iter.next();
    V value = map.get(key);
}
```

4.2.3. 반복자2
--------------
```java
Set<Map.Entry<K, V>> entrySet = map.entrySet();
Iterator<Map.Entry<K ,V>> iter = entrySet.iterator();
while(iter.hasNext()) {
    Map.Entry<K, V> entry = iter.next();
    K key = entry.getKey();
    V value = entry.getValue();
}
```
4.3. HashMap
=============
- HashMap의 Key로 사용할 객체는 haseCode()와 equals() 메소드를 오버라이딩해서 **동등 객체**가 될 조건을 정의해야 한다.
- 그로 인해, 중복 저장을 방지한다.
- 동등 객체의 조건
    - hashCode()의 리턴 값이 같다.
    - equals()의 결과가 true다.

4.3.1. HashMap 생성 방법
------------------------
```java
Map<K, V> map = new HashMap<K, V>();
```
- 키와 값의 타입은 기본 타입(byte, short, int, float, double, boolean, char)은 사용할 수 없다.
- 클래스 및 인터페이스 타입만 사용할 수 있다.
```java
Map<String, Integer> map = new HashMap<String, Integer>();
```

4.3.2. HashMap 실습
-------------------
```java
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

main() {

    // Map 컬렉션 생성
    Map<String, Integer> map = new HashMap<>();

    // 객체 저장
    map.put("a", 1);
    map.put("b", 2);
    map.put("c", 3);
    map.put("b", 4); // b의 key가 같기 때문에 마지막에 저장한 값(4)가 대체됨
    
    System.out.println(map.size()); // 3

    // 객체 찾기
    int value = map.get("b");

    // 객체를 하나씩 처리하기
    Set<String> keySet = map.keySet(); // Map 컬렉션에 저장된 모든 키를 Set으로 리턴
    Iterator<String> keyIter = keySet.iterator();   // 반복자 생성
    while(keyIter.hasNext()) {  // 반복할 값이 있다면 반복
        String key = keyIter.next();    // 한 번 반복할 때 마다 next key를 key에 저장
        Integer value = map.get(key);   // key에 대한 value 저장
        System.out.println(key + ":" + value);
    }
    System.out.println();

    // 객체 삭제
    map.remove("b");
    System.out.println(map.size()); // 2

    // 객체를 하나씩 처리
    Set<Map.Entry<String, Integer>> entrySet = map.entrySet(); // K, V 쌍으로 구성된 모든 Map.Entry 객체를 Set에 담아 리턴
    Iterator<Map.Entry<String, Integer>> entryIter = entrySet.iterator();

    while(entryIter.hasNext()) {
        Map.Entry<String,Integer> entry = entryIter.next();
        String eKey = entry.getKey();
        Integer eValue = entry.getValue();
        System.out.println(eKey + ":" + eValue);
    }
    System.out.println();

    // 객체 전체 삭제
    map.clear();
    System.out.println(map.size); // 0
}
```

4.3.3. HashMap 실습2
--------------------
- HashMap은 기본 타입은 사용할 수 없고, 클래스 및 인터페이스 타입을 사용할 수 있다고 했다.
- Student 객체를 키로 하고 점수를 값으로 저장하는 HashMap을 사용해 보자.
- 이때, 학번과 이름이 동일한 Student를 동등 키로 간주하고 중복 저장을 방지한다.
```java
class Student {
    public int sno;
    public String name;

    public Student(int sno, String name) {
        this.sno = sno;
        this.name = name;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Student) {
            Student student = (Student) obj;
            // equals가 true면 동등 키
            return (sno == student.sno) && (name.equals(student.name));
        } else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return name.hashCode() + sno;   // 학번과 이름이 같으면 동등 키
    }
}

class HashMapExam {
    main() {
        Map<Student, Integer> map = new HashMap<>();

        map.put(new Student(1, "홍길동"), 95);
        map.put(new Student(1, "홍길동"), 95); // 학번과 이름이 동일한 Student를 키로 저장

        Syetem.out.println(map.size()); // 동등 키 만족으로 중복 저장이 안되니 결과는 (1)이 된다.
    }
}
```
   
4.4. HashTable
==============
- HashMap과 동일한 내부 구조
- 차이점
    - 동기화된 메소드로 구성되어 있어 멀티 스레드가 동시에 HashTable 메소드를 실행할 수 없고, 하나의 스레드가 이를 완료해야
    - 다음 스레드가 사용할 수 있는 Thread-safe 구조이다.
   
4.4.1. HashTable 생성 방법
--------------------------
```java
Map<K, V> map = new HashTable<K, V>();
```
```java
Map<String, Integer> map = new HashTable<>();
```

4.4.2. HashTable 실습
---------------------
- 아이디 / 비밀번호 체크
```java
class HashTableExam {
    main() {
        Map<String, String> map = new HashTable<>();
        
        map.put("spring", "12");
        map.put("summer", "123");
        map.put("fall", "1234");
        map.put("winter", "12345");

        Scanner scan = new Scanner(System.in);

        while(true) {
            Syetem.out.print("ID> ");
            String id = scan.nextLine();
            Syetem.out.print("PWD> ");
            String pwd = scan.nextLine();
            System.out.println();

            if(map.containsKey(id)) {           // 먼저, map에 입력한 id가 key로 있는지 확인하고 
                if(map.get(id).equals(pwd)){    // 해당 id가 입력한 pwd와 같은지 확인 (map.get(key)는 주어진 key에 대한 value 리턴)
                    System.out.println("로그인 되었습니다. ");
                    break;
                } else {
                    System.out.println("비밀번호가 일치하지 않습니다. ");
                }
            } else {
                System.out.println("아이디가 존재하지 않습니다. ");
            }
        }
        
    }
}
```
