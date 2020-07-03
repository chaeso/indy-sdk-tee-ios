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

static NSString* config = @"{\"id\":\"x4461xx1112\"}";
static NSString* credentials = @"{\"key\": \"x4461xx1112\"}";

const unsigned char *secure_enclave_enc(indy_handle_t handle, const unsigned char *msg, const unsigned int len, unsigned int *resultLen) {
    CFErrorRef error = NULL;
    
    NSLog(@"\n secure_enclave_enc STARTED \n");
    
    printf(" [enc] input msg = %s ", msg);

    NSError *compressError = [NSError errorWithDomain:@"SecKeyError" code:3 userInfo:nil];
    const NSData* compressed = [NSData dataWithBytes:(const void *)msg length:len];

    NSData* cipherText = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(publicKeyRef, kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA512AESGCM, (__bridge CFDataRef)compressed, &error));
    
    *resultLen = [cipherText length];
    unsigned char* ret = (const unsigned char*)[cipherText bytes];
    
    NSLog(@"\n secure_enclave_enc ENDED \n");

    return ret;
}

const unsigned char *secure_enclave_dec(indy_handle_t handle, const unsigned char *msg, const unsigned int len, unsigned int *resultLen) {
    
    NSLog(@"\n secure_enclave_dec STARTED \n");
    CFErrorRef error = kCFSocketLeaveErrors;
    NSError *compressError = [NSError errorWithDomain:@"SecKeyError" code:3 userInfo:nil];

    const NSData* cipherText = [NSData dataWithBytes:(const void *)msg length:len];

    NSData* plainText = (NSData*)CFBridgingRelease(SecKeyCreateDecryptedData(privateKeyRef, kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA512AESGCM, (__bridge CFDataRef)cipherText, &error));

    *resultLen = [plainText length];
    unsigned char* result = (unsigned char*)[plainText bytes];
    
    printf("\n [dec] result plaintext = %s\n", result);

    return result;
}


void handle_result2(indy_handle_t command_handle_, indy_error_t err) {
}

void handle_result(indy_handle_t command_handle_, indy_error_t err) {
    NSLog(@"handle_result() - started");

    indy_error_t ret = indy_delete_wallet(command_handle_,
            [config UTF8String],
            [credentials UTF8String],
            handle_result2
    );
    
    NSLog(@"handle_result() - %@", ret);
}


const void secure_enclave_keygen() {
    printf("\n secure_enclave_keygen() - started\n");
    
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
    NSLog(@"handleError - ");
    NSLog(err);
}

- (void)viewDidLoad {
    indy_register_tee_method(secure_enclave_keygen, secure_enclave_enc, secure_enclave_dec);

    indy_handle_t handle = 1;

    CFTimeInterval startTime = CACurrentMediaTime();

    indy_error_t ret = indy_create_wallet(handle,
            [config UTF8String],
            [credentials UTF8String],
            handle_result
    );
    
    ret = indy_open_wallet(handle,
            [config UTF8String],
            [credentials UTF8String],
            handle_result
    );
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;

    NSLog(@"timeInterval = %d", elapsedTime);

    [super viewDidLoad];
    
    NSLog(@"End of viewDidLoad");
}


@end
