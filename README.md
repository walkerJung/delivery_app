# 기본 UI 작업하기

## 1. 색상 상수 지정하기
<details>
<summary> 내용 보기</summary>
<br>

- 폴더구조는 기능에 따라 나눈다.
- lib/common 을 만들어서 기능에 상관없이 공통으로 쓰는 부분을 정의한다.
- lib/common/const 에 colors.dart 파일을 만들어서 앱에 사용할 색상을 미리 정의한다.

</details>

## 2. 텍스트필드 디자인하기
<details>
<summary> 내용 보기</summary>
<br>

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
</details>

## 3. UI 배치하기
<details>
<summary> 내용 보기</summary>
<br>

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
</details>

## 4. UI 마무리하기
<details>
<summary> 내용 보기</summary>
<br>

- TextFormField 의 enabledBorder 속성을 설정하면 사용할수 있는 상태일때만 border 설정이 적용된다.
- 스크롤이 필요한 스크린은 SingleChildScrollView 로 감싸주고 SingleChildScrollView 의 keyboardDismissBehavior 속성을 설정하면 동작에 따라 키보드가 사라지게 할수 있다.

    ```
        // 스크롤 시 키보드 사라짐

        SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag
        )
    ```
</details>
<br/><br/>

# Authentication

## 1. Dio 로 Auth API 요청해보기
<details>
<summary> 내용 보기</summary>
<br>

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
</details>

## 2. 간단한 로그인 시스템 만들어보기
<details>
<summary> 내용 보기</summary>
<br>

- 기존에 하드코딩 되어있던 부분을 username 과 password 변수를 만들어서 로그인에 사용하도록 변경하였다.
</details>

## 3. SplashScreen 구현해보기
<details>
<summary> 내용 보기</summary>
<br>

- 로그인 성공 후 토큰 정보를 flutter secure storage 에 저장한다.

    ```
        // const/data.dart 에 토큰 변수 및 storage 생성

        const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
        const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

        const storage = FlutterSecureStorage();

        // 로그인 완료 후 저장

        final refreshToken = resp.data['refreshToken'];
        final accessToken = resp.data['accessToken'];

        await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
    ```

- SplashScreen 을 만들어서 storage 에 토큰이 저장되어 있는지 확인한다.

    ```
        void checkToken() async {
            final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
            final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

            if (refreshToken == null || accessToken == null) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                );
            } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                    builder: (_) => const RootTab(),
                ),
                    (route) => false,
                );
            }
        }
    ```
- initState 에선 await 를 사용할수 없으므로 다른 함수를 만들어서 호출해야 한다.

    ```
        void initState() {
            super.initState();

            checkToken();
        }
    ```
- SplashScreen 에서 토큰이 있는지 확인 및 토큰 검증 후 화면 이동이 발생하는게 전반적인 앱 흐름이다.
</details>

<br/><br/>

# Pagination

## 1. AppBar 와 TabBar 만들기
<details>
<summary> 내용 보기</summary>
<br>

- DefaultLayout 에 title, bottomNavigationBar 속성을 추가한다.

    ```
        final String? title;
        final Widget? bottomNavigationBar;
    ```
- Scaffold 위젯의 appBar, bottomNavigationBar 속성을 사용해 AppBar 와 TabBar 를 구현할수 있다.
- appBar 속성은 AppBar 를 return 하는 renderAppBar 함수를 만들어서 사용하면 편하다.

    ```
        AppBar? renderAppBar() {
            if (title == null) {
                return null;
            } else {
                return AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: Text(
                        title!,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                        ),
                    ),
                    foregroundColor: Colors.black,
                );
            }
        }
    ```
- bottomNavigationBar 속성은 DefaultLayout 을 사용하는 위젯에서 설정할수 있도록 구현하면 편하다.

    ```        
        // items 는 2개 이상부터 사용 가능

        bottomNavigationBar: BottomNavigationBar(
            items: const[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: '홈',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.fastfood_outlined),
                    label: '음식',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    label: '주문',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: '프로필',
                )
            ]
        )
    ```
- BottomNavigationBar() 의 속성을 사용하여 디자인을 변경할수 있다.

    ```
        selectedItemColor: PRIMARY_COLOR,       // 탭 선택 시 color
        unselectedItemColor: BODY_TEXT_COLOR,   // 선택 안된 탭 color
        selectedFontSize: 10,                   // 탭 선택 시 fontsize
        unselectedFontSize: 10,                 // 선택 안된 탭 fontsize
        type: BottomNavigationBarType.shifting, // 선택 되었을때의 에니메이션 (shifting 은 선택된 탭이 점유하는 공간이 살짝 넒어짐)
        onTap: (int index) {                    // 탭 선택 시 callback function
          setState(() {
            this.index = index;
          });
        },
        currentIndex: index,                    // 선택된 탭의 인덱스
    ```
</details>

## 2. TabBarView 생성하기
<details>
<summary> 내용 보기</summary>
<br>

- TabBarView 는 말그대로 TabBar 를 선택했을때 보이는 화면을 설정하는 위젯이다.
- TabBarView 위젯의 children 속성에 각 탭에 연결할 화면 위젯들을 추가하는 방식으로 연결한다.
- TabBarView 를 사용할땐 TabController 가 필요하고, controller 에 이벤트를 바인딩하여 사용한다.

    ```
        late TabController controller;

        @override
        void initState() {
            super.initState();
            controller = TabController(length: 4, vsync: this);
            controller.addListener(tabListenr);
        }

        @override
        void dispose() {
            controller.removeListener(tabListenr);
            super.dispose();
        }

        void tabListenr() {
            setState(() {
                index = controller.index;
            });
        }
    ```
- 에니메이션과 관련된 controller 를 사용할때 vsync 를 인자로 받는경우가 있는데 이럴땐 무조건 SingleTickerProviderStateMixin 을 with 로 추가해주고 vsync 인자에는 this 를 넘겨준다.

    ```
        class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin
    ```
- BottomNavigationBar 의 onTap 속성의 콜백함수에 controller 의 animateTo() 메서드를 사용하여 화면전환이 가능하도록 한다.

    ```
       onTap: (int index) {
          controller.animateTo(index);
        }, 
    ```
- TabBar 클릭 시 변경되는 이벤트는 controller 의 addListenr() 메서드를 사용하여 BottomNavigationBar 에서 참조하고있는 index 값을 controller 의 index 값으로 변경시켜준다.
- TabBarView 의 physics 속성을 설정하면 스와이프 기능이 안되도록 막을수 있다.

    ```
        TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            ...
        )
    ```
- controller 를 사용할때 late 로 변수를 생성해주고 initState 에서 할당해주고, 꼭 dispose 도 해줘야한다.
- TabController 는 TabBar 와 TabBarView 를 관리하는 컨트롤러 이다.
</details>

## 3. RestaurantCard 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- restaurant_screen.dart 를 만들어서 TabVarBiew 의 인자로 넘겨준다.
- Image.asset() 을 사용할때 fit 속성을 사용하면 이미지가 어떻게 랜더링 될지 설정할수 있다.

    ```
        Image.asset(            
            'asset/img/food/ddeok_bok_gi.jpg',
            fit: BoxFit.cover,
        )
    ```
- List 형식의 데이터에 join 메서드를 사용하면 리스트를 순회하며 구분자를 넣어준다.

    ```
        Text(
            tags.join(' · '),
            style: const TextStyle(
                color: BODY_TEXT_COLOR,
                fontSize: 14,
            ),
        ),
    ```
- ClipRrect 위젯을 사용하여 child 에 image 를 전달하면 image 에 border 효과를 줄수 있다.

    ```
       ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image,
        ), 
    ```
</details>

## 4. Refresh Token 확인 로직
<details>
<summary> 내용 보기</summary>
<br>

- splash_screnn.dart 에서 try catch 를 사용해서 refresh token 으로 api call 이 가능한지 확인하는 로직을 추가했다.

</details>

## 4. Restaurant Pagination 요청해보기
<details>
<summary> 내용 보기</summary>
<br>

- splash_screen.dart 에서 checkToken() 함수 내에 refreshToken 으로 accessToken 을 재발급 해서 storage 에 넣는 로직을 추가하였다.
- Future 를 return 하는 함수에서 api call 을 하고 FutureBuilder 의 future 속성에 전달해서 ListView 를 완성했다.

    ```
        Future<List> paginateRestaurant() async {
            final dio = Dio();

            final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

            final resp = await dio.get(
                'http://$ip/restaurant',
                options: Options(
                    headers: {'authorization': 'Bearer $accessToken'},
                ),
            );

            return resp.data['data'];
        }

        FutureBuilder(
            future: paginationRestaurant(),
            builder: ...
        )        
    ```
- ListView.separated 를 사용해서 각 item 사이에 구분자(SizedBox) 를 추가하였다.

    ```
        ListView.separated(
            ...
            separatorBuilder: (_, index) {
                return const SizedBox(
                    height: 16,
                );
            },
        )
    ```
- dynamic 관련 에러가 뜨는경우 형변환을 해줄수있다

    ```
        tags: List<String>.from(item['tags'])
    ```
</details>

<br/><br/>

# 데이터 모델링

## 1. JSON 데이터 매핑하기

- 개발 편의성을 위해 Future 타입의 response.data 를 모델의 인스턴스로 파싱하는 작업이 필요하다.