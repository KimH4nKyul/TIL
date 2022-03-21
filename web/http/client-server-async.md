```
친구가 스프링부트를 사용하면서 왜 RestController를 사용해야 하고,   
왜 프론트엔드 서버에서 JSON을 응답으로 받아야 하는지 물어봤는데   
설득은 했지만 파편적으로 흩어진 지식 때문에 제대로 정리해서 전달하진 못했다.  
이 문서를 작성하면서 제대로 정리해보고 누군가 이 문제에 대해 다시 내게 물어본다면 제대로 답변해주고 싶다. 😊  
```

# 클라이언트-서버 비동기 통신 

- 클라이언트에서 서버로 통신하는 메시지를 요청(Request) 메시지라고 하고,
- 서버에서 클라이언트로 통신하는 메시지를 응답(Response) 메시지라 한다.
- 웹에서 새로고침없이 이루어지는 동작을 위해 `비동기 통신` 해야 한다.  
- 비동기 통신을 위해서는 요청 메시지, 응답 메시지 모두 HTTP 본문(`Body`)에 데이터를 담아 보내야 한다.  
- Body에 담기는 데이터 형식은 여러가지가 있지만 주로 `JSON` 이다.
- `SpringBoot` 에서는 요청/응답에 대한 `JSON -> 자바 객체 -> JSON` 에 대한 변환이 가능하다.
- 이를 가능케 해주는 것이 `@RequestBody`와 `@ResponseBody` 이다. 
- @RequestBody와 @ResponseBody에 대한 내용은   
  https://github.com/KimH4nKyul/TIL/blob/main/dev/java/springboot/response-entity.md 에 있다.
