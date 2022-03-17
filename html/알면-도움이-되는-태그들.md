# 알면 도움이 되는 HTML 태그

## progress
<progress></progress>

* `<progress .. ></progress>`

## meter
<meter min='0' max='100' low='20' high='65' optimum='15' value='79'></meter>

* `<meter .. ></meter>`
* progress 태그와 연관

## details

## summary

<details>
    <summary>
        What is the best?
    </summary>
    <ul>
        <li>java</li>
        <li>javascript</li>
    </ul>
</details>

* `<summary></summary>`
* details 태그와 연관

## input type="time"

<input type="time"/>  

* 시간

<input tpye="week"/>

* 주간

## picture

```html
<picture>
    <source srcset="https://miro.medium.com/max/862/1*Oj22Mvo-o6n-5IzHR-9aGQ.png" media="(min-width:1200px)"/>
    <!-- 브라우저가 picture, source 제공하지 않는 경우 -->
    <img src="https://miro.medium.com/max/862/1*Oj22Mvo-o6n-5IzHR-9aGQ.png"/>
</picture>
```

* 웹브라우저/태블릿/모바일 환경에 맞춰 이미지를 다르게 표시
* `<img/>`, `<source/>` 와 함께 사용

## datalist

<label for="movie">What is your favourite movie?</label>
<input type="text" list="movie-options"/>
<datalist id="movie-options">
    <option value="Dune"/>
    <option value="Starwars"/>
    <option value="Matrix"/>
</datalist>

* JS 작성 없이, Auto complete(자동완성)이 가능케함

