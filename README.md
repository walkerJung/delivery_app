# 기본 UI 작업하기

## 1. 색상 상수 지정하기

- 폴더구조는 기능에 따라 나눈다.
- lib/common 을 만들어서 기능에 상관없이 공통으로 쓰는 부분을 정의한다.
- lib/common/const 에 colors.dart 파일을 만들어서 앱에 사용할 색상을 미리 정의한다.

## 2. 텍스트필드 디자인하기

- TextFormField 의 cursorColor 속성을 설정하면 깜빡이는 커서의 색상을 변경할수 있다.
- TextFormField 의 obscureText 속성을 설정하면 비밀번호 입력 시 * 로 표현된다.
- TextFormField 의 autofocus 속성을 설정하면 화면에 해당 위젯이 나오면 자동으로 focus 시킬수 있다.
- TextFormField 의 decoration 속성에 InputDecoration() 를 사용하면 다양한 UI 설정을 할수 있다.
- baseBorder 를 선언해놓고 copyWith 로 복사해서 사용하고, 필요한 속성만 다시 수정하는 방법으로 UI 를 만들어야 한다.

    ```

        const baseBorder = OutlineInputBorder(
            borderSide: BorderSide(
                color: INPUT_BORDER_COLOR,
                width: 1.0,
            ),
        );

        ...

        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20),
            hintText: "힌트 텍스트",
            errorText: "에러 텍스트",
            hintStyle: const TextStyle(
                color: BODY_TEXT_COLOR,
                fontSize: 14.0,
            ),
            fillColor: INPUT_BG_COLOR,
            filled: true,   // fillColor 로 설정한 색을 적용할지 않할지 결정하는 속성
            border: baseBorder,
            focusedBorder: baseBorder.copyWith(
                borderSide: baseBorder.borderSide.copyWith(
                    color: PRIMARY_COLOR,
                ),
            ),
        )
    ```
## 3. UI 배치하기

- Image.asset() 을 사용해서 asset 에 등록한 이미지를 불러올수 있다.
- pubspect.yaml 에 font 를 등록하고 MaterialApp 의 theme 속성에 font 를 추가할수 있다.

    ```
        theme: ThemeData(
          fontFamily: 'NotoSans',
        ),
    ```
- default_layout.dart 는 Scaffold 에 전달받은 child 를 그려주는 역할을 하는데 전체 스크린에 추가되어야할 로직이 있을때 default_layout.dart 만 수정하면 되기때문에 생산성에 도움을 준다.

    ```
        // 로그인 스크린의 return 을 DefaultLayout 에 child 를 넘겨주는 식으로 구현

        class LoginScreen extends StatelessWidget {

            ...

            @override
            Widget build(BuildContext context) {
                return DefaultLayout(
                    child: ...
                )
            }


        }
    ```
- MediaQuery 를 사용해서 width 값을 조정하면 편리하다

    ```
        Image.asset(
            'asset/img/misc/logo.png',
            width: MediaQuery.of(context).size.width / 3 * 2,
        ),
    ```
- Text 위젯 내에서 \n 을 사용하면 줄바꿈을 할수 있다.

## 4. UI 마무리하기

- TextFormField 의 enabledBorder 속성을 설정하면 사용할수 있는 상태일때만 border 설정이 적용된다.
- 스크롤이 필요한 스크린은 SingleChildScrollView 로 감싸주고 SingleChildScrollView 의 keyboardDismissBehavior 속성을 설정하면 동작에 따라 키보드가 사라지게 할수 있다.

    ```
        // 스크롤 시 키보드 사라짐

        SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag
        )
    ```

# Authentication

## 1. Dio 로 Auth API 요청해보기

- 기본적으로 로그인 할때 Basic userid:password 를 header 에 담아 요청한다.
- 토큰을 사용하는 인증은 Bearer token 을 header 에 담아 요청한다.
- base64 로 encode 하는 부분은 공통 유틸로 빼서 사용하면 편하다.
    ```
        const rawString = 'test@codefactory.ai:testtest';
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        String token = stringToBase64.encode(rawString);
    ```
- dio 의 option 속성에 header 관련 정보를 추가할수 있다.
    ```
        final resp = await dio.post(
            'http://$ip/auth/login',
            options: Options(
                headers: {'authorization': 'Basic $token'},
            ),
        );
    ```