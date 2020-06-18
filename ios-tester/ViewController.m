//
//  ViewController.m
//  ios-tester
//
//  Created by chaeso on 2020/04/06.
//  Copyright © 2020 chaeso. All rights reserved.
//

#import "ViewController.h"
#import "libindy.h"

//#import "IndyWallet.h"

#define kPrivateKeyName @"com.sk.app.test3"
#define newCFDict CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)

static SecKeyRef publicKeyRef;
static SecKeyRef privateKeyRef;
static NSData    *publicKeyBits;

static NSString* config = @"{\"id\":\"x4461xx112\"}";
static NSString* credentials = @"{\"key\": \"x4461xx112\"}";

const unsigned char *secure_enclave_enc(indy_handle_t handle, const unsigned char *msg, const unsigned int len, unsigned int *resultLen) {
    CFErrorRef error = NULL;

    NSError *compressError = [NSError errorWithDomain:@"SecKeyError" code:3 userInfo:nil];
    const NSData* compressed = [NSData dataWithBytes:(const void *)msg length:len];

    NSData* cipherText = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(publicKeyRef, kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA512AESGCM, (__bridge CFDataRef)compressed, &error));
    
    *resultLen = [cipherText length];
    unsigned char* ret = (const unsigned char*)[cipherText bytes];
    return ret;
}

const unsigned char *secure_enclave_dec(indy_handle_t handle, const unsigned char *msg, const unsigned int len, unsigned int *resultLen) {
    CFErrorRef error = kCFSocketLeaveErrors;
    NSError *compressError = [NSError errorWithDomain:@"SecKeyError" code:3 userInfo:nil];

    const NSData* cipherText = [NSData dataWithBytes:(const void *)msg length:len];

    NSData* plainText = (NSData*)CFBridgingRelease(SecKeyCreateDecryptedData(privateKeyRef, kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA512AESGCM, (__bridge CFDataRef)cipherText, &error));

    *resultLen = [plainText length];
    unsigned char* result = (unsigned char*)[plainText bytes];
    
    printf("\n Final plain text = %s\n", result);

    return result;
}


void handle_result2(indy_handle_t command_handle_, indy_error_t err) {
    printf("handle_result2 !!! called");
//    NSLog(@"error = %@", err);
}

void handle_result(indy_handle_t command_handle_, indy_error_t err) {
    indy_error_t ret2 = indy_delete_wallet(command_handle_,
            [config UTF8String],
            [credentials UTF8String],
            handle_result2
    );
    NSLog(@"ret2 = %@", ret2);

    printf("handle_result !!! called");
}


const void secure_enclave_keygen() {
    printf("Key gen using Secure Enclave (iOS) - started\n");
    
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(
      kCFAllocatorDefault,
      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
      kSecAccessControlTouchIDAny | kSecAccessControlPrivateKeyUsage,
      &error
    );
    
    // create dict of private key info
     CFMutableDictionaryRef accessControlDict = newCFDict;;
     CFDictionaryAddValue(accessControlDict, kSecAttrAccessControl, sacObject);
     CFDictionaryAddValue(accessControlDict, kSecAttrIsPermanent, kCFBooleanTrue);
     CFDictionaryAddValue(accessControlDict, kSecAttrLabel, kPrivateKeyName);

     // create dict which actually saves key into keychain
     CFMutableDictionaryRef generatePairRef = newCFDict;
     CFDictionaryAddValue(generatePairRef, kSecAttrTokenID, kSecAttrTokenIDSecureEnclave);
     CFDictionaryAddValue(generatePairRef, kSecAttrKeyType, kSecAttrKeyTypeECSECPrimeRandom);
     CFDictionaryAddValue(generatePairRef, kSecAttrKeySizeInBits, (__bridge const void *)([NSNumber numberWithInt:256]));
     CFDictionaryAddValue(generatePairRef, kSecPrivateKeyAttrs, accessControlDict);

     OSStatus status = SecKeyGeneratePair(generatePairRef, &publicKeyRef, &privateKeyRef);
    if (status == errSecSuccess) {
        NSLog(@"Key Generation SUCCESS ---------------");
    } else {
        NSError *error = [NSError errorWithDomain:@"SecKeyError" code:status userInfo:nil];
        NSLog(@" error => %@ ", [error userInfo] );
    }
    
    // [self savePublicKeyFromRef:publicKeyRef];
}

@interface ViewController ()

@end

@implementation ViewController

- (void)handleError: (NSError *)err {
    NSLog(@"error????");
    NSLog(err);
}

- (void)viewDidLoad {
//    secure_enclave_keygen();
//    const unsigned char* msg = "160d7789-bdf3-4a94-9faf-c86bd9f6213c.ff8a31cd-b2cb-402e-9cff-7ee50c277af2.83032d23-d01b-4c7e-bc46-096e2701acca.f2290f9b-d673-4a16-a67a-3b11b6f91412.80ce939e-126b-4a7f-a547-e275cbd6ead5.7cdc9bc5-39ba-4527-9a10-fc9440b260a7.e9897ee5-3a55-4eef-bc5d-4264efb5a0aksjdflkanvlanlefjaslkvnlaksnv30.dadb7c85-0160d7789-bdf3-4a94-9faf-c86bd9f6213c.ff8a31cd-b2cb-402e-9cff-7ee50c277af2.83032d23-d01b-4c7e-bc46-096e2701acca.f2290f9b-d673-4a16-a67a-3b11b6f91412.80ce939e-126b-4a7f-a547-e275cbd6eadasflkjaslkvjlkasdvjasd.fjli3j@#(@#(@(!(@(!@#5.7cdc9bc5-39ba-4527-9a10-fc9440b260a7.e9897ee5-3a55-4eef-bc5d-4264efb5a030.dadb7c85-06e6-4419-9041-880836df926e.47387fae-3a29-44f3-8f26-078fd6bb7bbf.76f7e148-22cf-413a-a185-e2f2d7b1c2de160d7789-bdf3-4a94-9faf-c86bd9f6213c.ff8a31cd-b2cb-402e-9cff-7ee50c277af2.83032d23-d01b-4c7e-bc46-096e2701acca.f2290f9b-d673-4a16-a67a-3b11b6f91412.80ce939e-126b-4a7f-a547-e275cbd6ead5.7cdc9bc5-39ba-4527-9a10-fc9440b260a7.e9897ee5-3a55-4eef-bc5d-4264efb5a030.dadb7c85-06e6-4419-9041-880836df926e.47387fae-3a29-44f3-8f26-078fd6bb7bbf.76f7e148-22cf-413a-a185-e2f2d7b1c2de6e6-4419-9041-880836df926e.47387fae-3a29-44f3-8f26-078fd6bb7bbf.76f7e148-22cf-413a-a185-e2f2d7b1c2de-end";
//    printf("\ndecryption result = %s\n", secure_enclave_dec(secure_enclave_enc(msg, strlen(msg))));

//    printf("\ncompressed result = <<<%s>>>\n", decompress(compress(msg, strlen(msg))));

    indy_register_tee_method(secure_enclave_keygen, secure_enclave_enc, secure_enclave_dec);

    indy_handle_t handle = 1;

    indy_error_t ret = indy_create_wallet(handle,
            [config UTF8String],
            [credentials UTF8String],
            handle_result
    );
    NSLog(@"end of ret = %@", ret);

    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}


@end
