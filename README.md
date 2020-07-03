# indy-sdk-tee-ios
TEE 가 적용된 Indy-SDK Demo App for iOS

# How to use

먼저 아래와 같이 라이브러리(libvcxall.a)를 빌드한 후 iOS 프로젝트에 import 시킨 후 빌드하면 된다.

```
git clone http://github.com/sktston/indy-sdk-tee
cd indy-sdk/libindy/build-combined
git checkout dev-extern-key
./setup.sh
./build.sh
cp output/libvcxall.a $INDY-SDK-TEE-IOS/ios-tester
```
