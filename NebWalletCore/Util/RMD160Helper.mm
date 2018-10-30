//
//  RMD160Helper.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/11.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "RMD160Helper.h"
#import "ripemd160.h"
#import "Util.h"

#define RMDsize 160

@implementation RMD160Helper

byte *RMD(byte *message, size_t length, size_t *hashLength) {
    dword         MDbuf[RMDsize/32];   /* contains (A, B, C, D(, E))   */
    static byte   hashcode[RMDsize/8]; /* for final hash-value         */
    dword         X[16];               /* current 16-word chunk        */
    unsigned int  i;                   /* counter                      */
    dword         nbytes;              /* # of bytes not yet processed */
    
    /* initialize */
    MDinit(MDbuf);
    
    *hashLength = RMDsize / 8;
    
    /* process message in 16-word chunks */
    for (nbytes = (uint32_t) length; nbytes > 63; nbytes -= 64) {
        for (i = 0; i < 16; i++) {
            X[i] = BYTES_TO_DWORD(message);
            message += 4;
        }
        MDcompress(MDbuf, X);
    }                                    /* length mod 64 bytes left */
    
    /* finish: */
    MDfinish(MDbuf, message, (uint32_t) length, 0);
    
    for (i=0; i<RMDsize/8; i+=4) {
        hashcode[i]   =  MDbuf[i >> 2];         /* implicit cast to byte  */
        hashcode[i+1] = (MDbuf[i >> 2] >>  8);  /*  extracts the 8 least  */
        hashcode[i+2] = (MDbuf[i >> 2] >> 16);  /*  significant bits.     */
        hashcode[i+3] = (MDbuf[i >> 2] >> 24);
    }
    
    return (byte *)hashcode;
}

+ (NSString *)rmd160:(NSString *)hexStr {
    NSData *data = [hexStr hexToData];
//    NSData *data = [hexStr dataUsingEncoding:NSUTF8StringEncoding];
    size_t hashLen;
    byte *hash = RMD((byte *)data.bytes, data.length, &hashLen);
    return [NSData dataWithBytes:hash length:hashLen].toHex;
}

@end
