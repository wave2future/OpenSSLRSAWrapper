// OpenSSLRSAWrapper.m
//
// Copyright (c) 2012 scott ban (http://github.com/reference)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OpenSSLRSAWrapper.h"

#define DocumentsDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define OpenSSLRSAKeyDir [DocumentsDir stringByAppendingPathComponent:@".openssl_rsa"]
#define OpenSSLRSAPublicKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"publicKey.pem"]
#define OpenSSLRSAPrivateKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"privateKey.pem"]

@implementation OpenSSLRSAWrapper
@synthesize publicKeyBase64,privateKeyBase64;

#pragma mark - getter

- (NSString*)publicKeyBase64{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:OpenSSLRSAPublicKeyFile]) {
        NSString *str = [NSString stringWithContentsOfFile:OpenSSLRSAPublicKeyFile encoding:NSUTF8StringEncoding error:nil];
        
        /*
         This return value based on the key that generated by openssl.
         
         -----BEGIN RSA PUBLIC KEY-----
         MIGHAoGBAOp5TLclpWChNDzHYPfB26SLmS8vlSAH4PyKopz5OS5Vx994FBQQLwv9
         2pIJQsBk09egwL0gbASK1VCwDt0MmaiyrNFl/xaEzB/VOvjoojBUzMMIcc9fKmo5
         GAzSbSP7we64dhvrziuuNVTuQ/e4XSa2skKFHMI0bCq4+pNYhvRhAgED
         -----END RSA PUBLIC KEY-----
         */
        return [[str componentsSeparatedByString:@"-----"] objectAtIndex:2];
    }
    return nil;
}

- (NSString*)privateKeyBase64{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:OpenSSLRSAPrivateKeyFile]) {
        NSString *str = [NSString stringWithContentsOfFile:OpenSSLRSAPrivateKeyFile encoding:NSUTF8StringEncoding error:nil];
        
        /*
         This return value based on the key that generated by openssl.
         
         -----BEGIN RSA PRIVATE KEY-----
         MIICXAIBAAKBgQDqeUy3JaTgmjQ8x2D3wduki5kvL5Ulx+D8iqKc+TkuVcffeBQU
         EC8L/dDSAULAZEPXoKW9IGwGibVQsA7dDJmosqzRZf8WhMwf1Tr46KIwVMzDCHGv
         XypseRgM0m0j+8HuuHYb684rrjVU1jP3tl0mtrJChRzCNGwquPqTWIb0YQIBAwKB
         gQCcUN0Pbm5AZs192kClK+fDB7t0ymNuhUCoXGxopiYe49qU+rgNYB9dU+cMBiyA
         QzflFch+FZ1YXI41yrSTXbvFhcYQy7jdFVJiqNH4Cu767ETzLMFDiDXIv6/h72iN
         hfeRWTW/KbyZbEtq/HeTjIg7rP3h8Fveh/Fj3EY4bmlqgwJBAPbQFmacHXeO4xcP
         aLhFVX/lDrmL7o1TIFNAp8xH/Kqf+L4+uSzoqyvPzO3w2ATdge+VnLhrxzzU48eg
         Y3wHpY2CQQDzM6HNza3tQajA8Jwf5mJygEeLw9uFhp8GZ5IfCFMILpv0ZsQASppf
         9GeFj8Jes0tDn9LkJy0rrTEm8Ns24S8PAkEApIq5mb1o+l9CD1+bJYOOVUAfJK1J
         s4zAN4Bv3YVTHGql1CnQyJscx9/d8/XlWJOr9Q5oevKE0ziX2mrs/VpuXwJBAKIi
         a96JHkjWcICgaBVO7ExVhQfX565Vv1maYWoFjLAfEqLvLVWHEZVNmlkKgZR3h4Jq
         jJgaHh0eIMSZkiSWH18CQGsFhFPdBonmeIm1kY1YWjpM4WS0kUlXOC3sCYg8eXFe
         YEEr9pnY+hhDFegEItQd1hAvrqQhpxhX7HhNNxUoPp4=
         -----END RSA PRIVATE KEY-----
         */
        return [[str componentsSeparatedByString:@"-----"] objectAtIndex:2];
    }
    return nil;
}

- (id)init{
    if (self = [super init]) {
        //load RSA if it is exsit
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:OpenSSLRSAKeyDir]) {
            [fm createDirectoryAtPath:OpenSSLRSAKeyDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }return self;
}

+ (id)shareInstance{
    static OpenSSLRSAWrapper *_opensslWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _opensslWrapper = [[self alloc] init];
    });
    return _opensslWrapper;
}

- (BOOL)generateRSAKeyPairWithKeySize:(NSInteger)keySize {
    if (NULL != _rsa) {
        RSA_free(_rsa);
        _rsa = NULL;
    }
    _rsa = RSA_generate_key(keySize,RSA_F4,NULL,NULL);
    assert(_rsa != NULL);
    
    if (_rsa) {
        return YES;
    }return NO;
    
    //    PEM_write_RSAPrivateKey(stdout, _rsa, NULL, NULL, 0, NULL, NULL);
    //    PEM_write_RSAPublicKey(stdout, _rsa);
}

- (BOOL)exportRSAKeys{
    assert(_rsa != NULL);
    
    if (_rsa != NULL) {
        FILE *filepub,*filepri;
        filepri = fopen([OpenSSLRSAPrivateKeyFile cStringUsingEncoding:NSASCIIStringEncoding],"w");
        filepub = fopen([OpenSSLRSAPublicKeyFile cStringUsingEncoding:NSASCIIStringEncoding],"w");
        
        if (NULL != filepub && NULL != filepri) {
            int retpri = -1;
            int retpub = -1;
            
            RSA *_pribrsa = RSAPrivateKey_dup(_rsa);
            assert(_pribrsa != NULL);
            retpri = PEM_write_RSAPrivateKey(filepri, _pribrsa, NULL, NULL, 512, NULL, NULL);
            RSA_free(_pribrsa);
            
            RSA *_pubrsa = RSAPublicKey_dup(_rsa);
            assert(_pubrsa != NULL);
            retpub = PEM_write_RSAPublicKey(filepub, _pubrsa);
            RSA_free(_pubrsa);
            
            fclose(filepub);
            fclose(filepri);
            
            return (retpri+retpub>1)?YES:NO;
        }
    }return NO;
}

- (BOOL)importRSAKeyWithType:(KeyType)type{
    FILE *file;
    
    if (type == KeyTypePublic) {
        file = fopen([OpenSSLRSAPublicKeyFile cStringUsingEncoding:NSASCIIStringEncoding],"rb");
    }else{
        file = fopen([OpenSSLRSAPrivateKeyFile cStringUsingEncoding:NSASCIIStringEncoding],"rb");
    }
    
    if (NULL != file) {
        
        if (type == KeyTypePublic) {
            _rsa = PEM_read_RSAPublicKey(file,NULL, NULL, NULL);
            assert(_rsa != NULL);
            // PEM_write_RSAPublicKey(stdout, _rsa);
        }else{
            _rsa = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL);
            assert(_rsa != NULL);
            PEM_write_RSAPrivateKey(stdout, _rsa, NULL, NULL, 0, NULL, NULL);
        }
        
        fclose(file);
        return (_rsa != NULL)?YES:NO;
    } return NO;
}


#pragma mark -

- (int)getBlockSizeWithRSA_PADDING_TYPE:(RSA_PADDING_TYPE)padding_type keyType:(KeyType)keyType{
    
    int len = RSA_size(_rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

- (NSData*)encryptRSAKeyWithType:(KeyType)keyType plainText:(NSString*)text{
    if (text && [text length]) {
        int status = RSA_check_key(_rsa);
        if (!status) {
            NSLog(@"status code %i",status);
            return nil;
        }
        
        NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:RSA_PADDING_TYPE_NONE keyType:KeyTypePrivate];
        //NSLog(@"---------- private encrypt block size length %i ----------",flen);
        
        char *encData =  (char *)malloc(flen);
        bzero(encData, flen);
        
        //It seems [publicKey cStringUsingEncoding:NSASCIIStringEncoding] doesn't work for the RSA_private_encrypt/RSA_public_encrypt methods of the parameter `from`.I've tried many times but failed.
        int length = [text length];
        unsigned char input[length+1];
        int i=0;
        for (; i<length; i++) {
            input[i] = [text characterAtIndex:i];
        }
        input[i] = '\0';//end of the string
        
        switch (keyType) {
            case KeyTypePrivate:{
                //start encrypt
                status =  RSA_private_encrypt(flen, (unsigned char*)input, (unsigned char*)encData, _rsa,  RSA_PADDING_TYPE_NONE);
                //NSLog(@"---------- private status %i ----------",status);
                
            }
                break;
                
            default:{
                //start encrypt
                status =  RSA_public_encrypt(flen, (unsigned char*)input, (unsigned char*)encData, _rsa,  RSA_PADDING_TYPE_NONE);
                //NSLog(@"---------- public status %i ----------",status);
            }
                break;
        }
        
        
        if (status) {
            /*
             NSLog(@"---------- private encrypt begin ----------");
             NSLog(@"%s",encData);
             NSLog(@"---------- private encrypt end ----------");
             
             NSLog(@"private encrypt data length is %zi",strlen((const char *)encData));
             */
            NSData *returnData = [NSData dataWithBytes:encData length:status];
            free(encData);
            encData = NULL;
            
            return returnData;
        }
        
        free(encData);
        encData = NULL;
    }
    return nil;
}

- (NSString*)decryptRSAKeyWithType:(KeyType)keyType data:(NSData*)data{
    if (data && [data length]) {
        
        int status = RSA_check_key(_rsa);
        if (!status) {
            NSLog(@"status code %i",status);
            return nil;
        }
        
        NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:RSA_PADDING_TYPE_NONE keyType:keyType];
        
        //alloc decoded space
        char *decData =  (char *)malloc(flen);
        bzero(decData, flen);
        
        switch (keyType) {
            case KeyTypePrivate: {
                //start decrypt
                status =  RSA_private_decrypt(flen, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa,  RSA_PADDING_TYPE_NONE);
                assert(status);
                
            }
                break;
                
            default: {
                //start decrypt
                status =  RSA_public_decrypt(flen, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa,  RSA_PADDING_TYPE_NONE);
                assert(status);
            }
                break;
        }
        
        if (status) {
            /*
             NSLog(@"-------------Private Decrypt begin------------");
             NSLog(@">>>>>>>>>>>>>>>%s<<<<<<<<<<<",decData);
             NSLog(@"-------------Private Decrypt end------------");
             */
            NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData
                                                                             length:status
                                                                           encoding:NSASCIIStringEncoding];
            /*
             NSLog(@"----->>>>%@<<<<",decryptString);
             NSLog(@"private decrypt data length is %zi",strlen((const char *)decData));
             */
            free(decData);
            decData = NULL;
            
            return decryptString;
        }
        free(decData);
        decData = NULL;
    }
    return nil;
}
@end
