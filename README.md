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
<details>
<summary> 내용 보기</summary>
<br>

- 개발 편의성을 위해 Future 타입의 response.data 를 모델의 인스턴스로 파싱하는 작업이 필요하다.

</details>

## 2. fromJson 생성자 만들어보기
<details>
<summary> 내용 보기</summary>
<br>

- fromJson 생성자는 json 으로부터 데이터 모델링 및 인스턴스화 시키는걸 의미한다.
- Dart 에서 Json 의 형식은 Map<String, dynamic> 이다
- factory 생성자를 사용해서 fromJson 생성자를 만들고 response.data 를 넘겨받아서 데이터를 인스턴스화 시킨다.

```
    factory RestaurantModel.fromJson({required Map<String, dynamic> json}) {
        return RestaurantModel(
            id: json['id'],
            name: json['name'],
            thumbUrl: 'http://$ip${json['thumbUrl']}',
            tags: List<String>.from(json['tags']),
            priceRange: RestaurantPriceRange.values.firstWhere(
                (e) => e.name == json['priceRange'],
            ),
            ratings: json['ratings'],
            ratingsCount: json['ratingsCount'],
            deliveryTime: json['deliveryTime'],
            deliveryFee: json['deliveryFee'],
        );
  }
```
</details>

## 3. fromModel 생성자 만들어보기
<details>
<summary> 내용 보기</summary>
<br>

- fromModel 생성자는 인스턴스화 된 model 로부터 데이터 모델링 및 인스턴스화 시키는걸 의미한다.
- fromJson 을 통해 인스턴스화 된 model 을 전달받아 factory 생성자를 사용해서 랜더링 할수있도록 인스턴스화 시킨다.

    ```
        factory RestaurantCard.fromModel({required RestaurantModel model}) {
            return RestaurantCard(
                image: Image.network(
                    model.thumbUrl,
                    fit: BoxFit.cover,
                ),
                name: model.name,
                tags: model.tags,
                ratingsCount: model.ratingsCount,
                deliveryTime: model.deliveryFee,
                deliveryFee: model.deliveryFee,
                ratings: model.ratings,
            );
        }
    ```
- 이러한 패턴으로 개발할때 유지보수성, UI 와 비지니스 로직 분리 등 다양한 이점을 가져갈수 있다.

    ```
        // 서버 응답 > fromJson 통해서 인스턴스화 > 인스턴스화 된 model 을 fromModel 에서 렌더링 관여 > UI / 비지니스 로직 분리 완료

        return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
                final item = snapshot.data![index];
                final pItem = RestaurantModel.fromJson(json: item);
                return RestaurantCard.fromModel(
                model: pItem,
                );
            },
            separatorBuilder: (_, index) {
                return const SizedBox(
                height: 16,
                );
            },
        );
    ```
</details>

<br/><br/>

# RestaurantDetailScreen 작업하기

## 1. 레스토랑 상세페이지 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- 위젯 안에서 if문을 쓰면 바로 아래만 적용된다.

    ```
        if (isDetail) image,
        if (!isDetail)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image,
          ),
    ```
</details>

## 2. ProductCard 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- Row 위젯 안에 있는 children 위젯들은 필요한 만큼 각각의 고유한 높이를 점유한다.
- 최대한 높이를 점유하게 하려면 IntrinsicHeight 위젯으로 감싸줘야 한다.
- 최대한 넓이를 점유하게 하려면 IntrinsicWidth 위젯으로 감싸줘야 한다.
- Text 위젯의 maxLines 과 overflow 속성을 설정하면 말 줄임표를 붙일수 있다.

    ```
        Text(
            '전통 떡볶이의 정석!\n맛있습니다!',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
                color: BODY_TEXT_COLOR,
                fontSize: 14,
            ),
        ),
    ```
</details>

## 3. SliverList 구현하기
<details>
<summary> 내용 보기</summary>
<br>

- 하나의 스크린에서 두개의 스크롤 가능한 리스트가 있을때 CustomScrollView 를 사용한다.
- CustomScrollView 의 slivers 속성에 들어가는 위젯들은 대부분 Slivers 로 시작한다.
- SliverList 위젯의 delegate 속성을 사용하여 빌더로 랜더( 화면에 보이는것들만 랜더 ) 할건지 children 형태로 랜더 할것인지 고를수 있다.
</details>

## 4. 레스토랑 상세요청 구현하기
<details>
<summary> 내용 보기</summary>
<br>

- 상세정보는 List 가 아닌 Map 형식의 response 를 받는다.
- api response -> RestaurantDetailModel.fromJson 으로 인스턴스화 -> RestaurantDetailModel 은 RestaurantModel 을 상속받았으므로 RestaurantModel 의 형식도 가진다. -> RestaurantCard.fromModel 로 인스턴스화 시키면서 랜더링 한다.
- 중복되는 데이터 모델링은 ( 예를 들어 리스트와 상세보기 관계 ) 자식 클래스에서 부모 클래스를 상속받아서 구현하면 깔끔하다.
- List 형식의 속성이 있다면 그 형식의 model 을 추가하면 깔끔하다.

    ```
        class RestaurantProductModel {
            final String id;
            final String name;
            final String imgUrl;
            final String detail;
            final int price;

            RestaurantProductModel({
                required this.id,
                required this.name,
                required this.imgUrl,
                required this.detail,
                required this.price,
            });
        }

        ...

        products: json['products']
          .map<RestaurantProductModel>(
            (x) => RestaurantProductModel(
              id: x['id'],
              name: x['name'],
              imgUrl: x['imgUrl'],
              detail: x['detail'],
              price: x['price'],
            ),
          )
          .toList(),
    ```
</details>

## 5. ProductCard 매핑하기
<details>
<summary> 내용 보기</summary>
<br>

- json 으로 부터 데이터 매핑이 필요하면 fromJson 생성자를 만들어서 인스턴스화 시키면 좋다.
- model 로 부터 데이터 매핑이 필요하면 fromModel 생성자를 만들어서 인스턴스화 시키면 좋다. (fromModel 은 주로 랜더링에서 사용)
</details>

<br><br>

# JsonSerializable과 Retrofit 그리고 Dio Interceptor

## 1. RestaurantModel에 JsonSerializable 적용해보기
<details>
<summary> 내용 보기</summary>
<br>

- JsonSerializable 는 코드 제너레이터 로써 fromJson, toJson 과 간단한 속성 변경에 도움을 주는 의존성 도구이다.
- https://github.com/google/json_serializable.dart/tree/master/example
- flutter pub run build_runner build 는 1회성 실행 CLI 이다.
- flutter pub run build_runner watch 는 변경사항이 생길시 자동으로 빌드를 해주는 CLI 이다.
- 기본적인 사용법은 모델 위에 @JsonSerializable() 어노테이션을 추가해주면 된다.

    ```
       @JsonSerializable()
        class RestaurantModel {}
    ```
- factory 패턴을 사용하여 기존의 fromJson 과 같은 JsonSerializable 가 만들어둔 fromJson 을 return 해주는 방식으로 사용한다.

    ```
       part 'restaurant_model.g.dart';

       factory RestaurantModel.fromJson(Map<String, dynamic> json) => _$RestaurantModelFromJson(json); 
    ```
- JsonSerializable 가 생성한 코드는 _$ + 모델명 + FromJson or ToJson 의 네이밍으로 생성된다.
- 일부 속성중에서 변경해야 할 속성이 있다면 변경할 속성 바로 위에 @JsonKey 어노테이션을 추가해서 변경할수 있다.

    ```
        // pathToUrl 의 value 파라미터에 thumbUrl 이 들어간다.

        @JsonKey(
            fromJson: pathToUrl,
        )
        final String thumbUrl;

        ...

        static pathToUrl(String value) {
            return 'http://$ip$value';
        }

    ```
</details>

## 2. RestaurantDetailModel에 JsonSerializable 적용해보기
<details>
<summary> 내용 보기</summary>
<br>

- part 'restaurant_detail_model.g.dart'; 를 추가한다.

    ```
        part 'restaurant_detail_model.g.dart';
    ```
- class 바로 위에 어노테이션을 추가한다.

    ```
        @JsonSerializable()
        class RestaurantDetailModel extends RestaurantModel {
            final List<RestaurantProductModel> products;
            ...
        }
    ```
- 인스턴스화 시킬때 다른 클래스의 형식을 참조하는 속성이 있다면 그 클래스도 JsonSerializable 을 해준다.

    ```
        @JsonSerializable()
        class RestaurantProductModel {}
    ```
- @JsonKey 내부에서 자주사용하게 되는 함수는 common/utils/data_utils.dart 로 빼서 사용하자.

    ```
        @JsonKey(
            fromJson: DataUtils.pathToUrl,
        )
    ```
</details>

## 3. Restaurant Repository 구현하기
<details>
<summary> 내용 보기</summary>
<br>

- 코드 제너레이터 사용을 위해 restaurant_repository.dart 를 만들고 part 를 작성한다.
- @RestApi() 어노테이션을 추가해주고, repository 클래스는 abstract 로 선언한다.

    ```
        part 'restaurant_repository.g.dart';

        @RestApi()
        abstract class RestaurantRepository {}
    ```
- 코드 제너레이터가 만들어준 _RestaurantRepository 를 factory 로 선언한다.

    ```
        factory RestaurantRepository(Dio dio, {String baseUrl}) = _RestaurantRepository;
    ```

- abstract 클래스 이므로 필요한 api 함수들의 body 는 선언하지 않는다.
- Future 와 어떤 model 의 형식 인지 제네릭 안에 넣어준다.

    ```
        @GET('/{id}')
        Future<RestaurantDetailModel> getRestaurantDetail({
            @Path() required String id,
        });
    ```
- repository 를 만들고 메서드를 호출하면 api response 가 fromJson 으로 파싱된후 return 된다.

    ```
        Future<RestaurantDetailModel> getRestaurantDetail() async {
            final dio = Dio();

            final repository =
                RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

            return repository.getRestaurantDetail(id: id);
        }
    ```
</details>

## 4. Dio onRequest Interceptor 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- Dio 의 Interceptor 를 사용하면 다양한 편의기능을 추가할수 있다.
- common/dio/dio.dart 에 CustomInterceptor 를 만들고 dio 의 Interceptor 를 상속받는다.

    ```
        class CustomInterceptor extends Interceptor {}
    ```
- onRequest 메서드는 api request 를 보내기 전에 실행되는 인터셉터이다.
- retrofit 의 @Headers 어노테이션에 전달한 map 을 interceptor 의 options 에서 확인할수 있다.

    ```
        @GET('/{id}')
        @Headers({'accessToken': 'true'})
        Future<RestaurantDetailModel> getRestaurantDetail({
            @Path() required String id,
        });

        ...

        @override
        void onRequest(
            RequestOptions options,
            RequestInterceptorHandler handler,
        ) async {
            if (options.headers['accessToken'] == 'true') {
                options.headers.remove('accessToken');

                final token = await storage.read(key: ACCESS_TOKEN_KEY);

                options.headers.addAll({'authorization': 'Bearer $token'});
            }

            if (options.headers['refreshToken'] == 'true') {
                options.headers.remove('refreshToken');

                final token = await storage.read(key: REFRESH_TOKEN_KEY);

                options.headers.addAll({'authorization': 'Bearer $token'});
            }

            return super.onRequest(options, handler);
        }
    ```
- api request 에 accessToken 이 필요한 repository 에서는 {'accessToken' : 'true'} 를 추가해준다.
- api request 에 refreshToken 이 필요한 repository 에서는 {'refreshToken' : 'true'} 를 추가해준다.
- api request 를 보내기 전에 onRequest 메서드가 실행되어 storage 의 토큰값을 {'authorization' : 'Bearer $token'} 형식으로 넣어준다.
</details>

## 4. Dio onError Interceptor 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- interceptor 의 onError 메서드를 사용하면 에러 핸들링을 할수 있다.
- err 에는 에러에 대한 정보, handler 는 이 에러를 reject, resolve 로 핸들링 할수 있다.

    ```
        return handler.reject(err);         // 에러 발생
        return handler.resolve(response);   // 에러 해결 후 에러 없던것처럼 Resolve
    ```
- storage 에 refreshToken 이 없다면 에러 발생
- 401 에러가 맞고 (err.response?.statusCode == 401) refreshToken 을 발급받으려던게 아니라면
- try catch 에서 accessToken 재발급 후
- 에러가 발생한 requestOption 의 header 에 새로 발급한 accessToken 넣어주기

    ```
        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;

        options.headers.addAll(
          {
            'authorization': 'Bearer $accessToken',
          },
        );
    ```
- storage 에 다시 저장 ( 다른 api request 에서 onRequest 가 먼저 실행되기 때문에 토큰 최신화 )
- accessToken 정보를 수정한 options 로 다시 fetch 후 결과 return

    ```
        final response = await dio.fetch(options);
        return handler.resolve(response);
    ```
- 즉 refreshToken 은 유효한데, accessToken 이 만료되었을때 accessToken 을 재발급 하고, 다시 요청하는 로직을 추가한 것이다.    
</details>

## 5. Restaurant Pagination API 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- retrofit 과 dio 로 api 통신을 편하게 할수 있다.
- 즉, JsonSerializable 은 fromJson, toJson 에 대한 코드 제너레이터 역할을 하고
- retrofit 으로 만든 abstract repository 에서 dio 를 전달받아서 api call 을 하고
- 그 과정에서 dio 의 intercepter 가 동작하고
- response 가 있으면 repository 에서 fromJson 으로 파싱 후 return 한다.
- @JsonSerializable 어노테이션의 genericArgumentFactories 속성을 사용하면 제네릭을 사용할수 있다.

    ```
        @JsonSerializable(
            genericArgumentFactories: true,
        )
        class CursorPaginationModel<T> {}
    ```
</details>

## 6. Pagination UI 에 적용해보기
<details>
<summary> 내용 보기</summary>
<br>

- retrofit 에서 만든 repository 는 항상 fromJson 까지 파싱해준다는걸 잊지말자.
</details>

<br><br>

# 상태관리 프로젝트에 적용하기

## 1. Dio에 Provider 적용하기
<details>
<summary> 내용 보기</summary>
<br>

- 함수의 body 안에서 state 를 사용할땐 read 메서드를 사용한다.
- Provider 안에서 다른 provider 를 사용할땐 Watch 메서드를 사용한다.
- dio 와 secure storage 를 하나의 state 로 만들고 Provider 로 dio 와 secure storage 를 합쳐서 사용한다.

    ```
        final dioProvider = Provider<Dio>(
            (ref) {
                final dio = Dio();
                final storage = ref.watch(secureStorageProvider);

                dio.interceptors.add(CustomInterceptor(storage: storage));
                return dio;
            },
        );
    ```
- ref.watch와 ref.read의 주요 차이점은 위젯이 프로바이더의 상태에 대해 "반응적 (build)"인지 아니면 "비반응적"인지를 결정한다는 것이다. 이에 따라 상황에 맞게 적절하게 선택하여 사용하면 된다.
- 이렇게 하나로 묶은 Provider 를 사용할때 이점은 어떤 스크린 에서든 똑같은 인스턴스를 사용할수 있다는 점이다.
</details>

## 2. RestaurantRepositoryProvider 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- screen 에서 dio 를 호출해서 response 를 받아올 필요없이 repository 안에서 Provider 로 사용하여 로직을 분리하였다.

    ```
        <!-- repository 내 Provider -->

        final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
            final dio = ref.watch(dioProvider);
            final repository = RestaurantRepository(
                dio,
                baseUrl: 'http://$ip/restaurant',
            );

            return repository;
        });

        <!-- UI screen -->
        future: ref.watch(restaurantRepositoryProvider).getRestaurantDetail(id: id),
    ```
- 
</details>

## 3. RestaurantProvider 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- restaurant provider 를 stateNotifier 로 만든다.
- 생성자 메서드 뒤에 함수 바디를 추가하고 함수를 호출하면 인스턴스화 될때 바로 그 함수가 실행된다.

    ```
        class RestaurantStateNotifier extends StateNotifier<List<RestaurantModel>> {
            final RestaurantRepository repository;

            RestaurantStateNotifier({required this.repository}) : super([]) {
                paginate();
            }

            paginate() async {
                final resp = await repository.paginate();

                state = resp.data;
            }
        }
    ```
- restaurant repository 도 Provider 로 만들어놨기 때문에 restaurantProvider 에서도 접근이 가능하다.

    ```
       final restaurantProvider =
            StateNotifierProvider<RestaurantStateNotifier, List<RestaurantModel>>(
            (ref) {
                final repository = ref.watch(restaurantRepositoryProvider);
                final notifier = RestaurantStateNotifier(repository: repository);

                return notifier;
            },
        ); 
    ```
- 즉, restaurantProvider 는 restaurantRepositoryProvider 의 paginate 메서드를 사용하여 notifier 를 return 하고 있다.
- 이렇게 Provider 를 만들경우 Future builder 를 사용할 필요가 없다.
</details>

## 4. CursorPagination 상태 작업하기
<details>
<summary> 내용 보기</summary>
<br>

- OOP 로 클래스 인스턴스에 상태를 추가하였다.
- 조부모 > 부모 > 자식 클래스 의 형태일 경우에 자식 클래스는 조부모, 부모 모두를 상속받는다는 개념을 잊지말자.

</details>

## 5. Pagination Params 추가하기
<details>
<summary> 내용 보기</summary>
<br>

- const 로 생성자를 만들어야 const 인스턴스화가 가능하다.
- Retrofit 을 사용할때 파라미터로 쿼리스트링을 받아야 할때 @Queries 어노테이션을 사용하면 된다.

    ```
        @GET('/')
        @Headers({'accessToken': 'true'})
        Future<CursorPaginationModel<RestaurantModel>> paginate({
            @Queries() PaginationParams? paginationParams = const PaginationParams(),
        });
    ```
</details>

## 6. Restaurant Pagination - 1
<details>
<summary> 내용 보기</summary>
<br>

- PaginationParams 같은 경우 인자값을 받아서 Json 으로 변환시켜서 보내야 하므로 toJson 이 필요하다.

    ```
        Map<String, dynamic> toJson() => _$PaginationParamsToJson(this);
    ```
- CursorPaginationBase 를 상속받고 있는 5가지 클래스가 있기때문에 RestaurantStateNotifier 의 state 타입은 CursorPaginationBase 가 되고 상속받고 있는 모든 클래스가 state 로 들어올수 있다.

    ```
        class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
            final RestaurantRepository repository;

            RestaurantStateNotifier({required this.repository})
                : super(CursorPaginationLoading()) {
                paginate();
            }

            paginate({
                int fetchCount = 20,
                bool fetchMore = false,
                bool forceRefetch = false,
            }) async {

            }
        }
    ```
</details>

## 7. Restaurant Pagination - 2
<details>
<summary> 내용 보기</summary>
<br>

- hasMore 가 false 인 경우는 이미 데이터를 한번 불러왔다는 의미이다.
- as 는 런타임 환경에서 타입이 100프로 맞을경우만 사용해야한다.

    ```
        // state 의 타입을 CursorPaginationBase 로 정해놨기때문에 as 를 써서 타입 확정

        if (state is CursorPaginationModel && !forceRefetch) {
            final pState = state as CursorPaginationModel;

            if (!pState.meta.hasMore) {
                return;
            }
        }
    ```
</details>

## 8. Restaurant Pagination - 3
<details>
<summary> 내용 보기</summary>
<br>

- fetchMore 가 true 이고 3가지 로딩 상황 중 하나라도 true 일 경우 return 

    ```
        final isLoading = state is CursorPaginationLoading;
        final isRefetching = state is CursorPaginationRefetching;
        final isFetchingMore = state is CursorPaginationFetchingMore;

        if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
            return;
        }
    ```
</details>