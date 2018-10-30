//
//  secp256k1.c
//  EthTest
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#include "gp_secp256k1.h"
#include "secp256k1.h"
#include "secp256k1_recovery.h"
#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>

static bool secp256k1_inited = false;
static secp256k1_context* secp256k1_ctx = NULL;
static pthread_mutex_t secp256k1_mutex;

void ecc_init(void) {
    if (!secp256k1_inited) {
        pthread_mutex_init(&secp256k1_mutex, NULL);
        secp256k1_inited = true;
    }
}

void ecc_start(void) {
    ecc_init();
    pthread_mutex_lock(&secp256k1_mutex);
    secp256k1_ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    assert(secp256k1_ctx != NULL);
//    uint8_t seed[32];
//    int ret = secp256k1_context_randomize(secp256k1_ctx, seed);
//    assert(ret);
}

void ecc_stop(void) {
    secp256k1_context* ctx = secp256k1_ctx;
    secp256k1_ctx = NULL;
    if (ctx) {
        secp256k1_context_destroy(ctx);
    }
    pthread_mutex_unlock(&secp256k1_mutex);
}

bool ecc_get_pubkey(const uint8_t* private_key, uint8_t* public_key, size_t* in_outlen, bool compressed) {
    if (!secp256k1_ec_seckey_verify(secp256k1_ctx, private_key)) {
        return false;
    }
    secp256k1_pubkey pubkey;
    assert(secp256k1_ctx);
    memset(public_key, 0, *in_outlen);
    if (!secp256k1_ec_pubkey_create(secp256k1_ctx, &pubkey, private_key)) {
        return false;
    }
    if (!secp256k1_ec_pubkey_serialize(secp256k1_ctx, public_key, in_outlen, &pubkey, compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED)) {
        return false;
    }
    return true;
}

bool ecc_private_key_tweak_add(uint8_t* private_key, const uint8_t* tweak) {
    assert(secp256k1_ctx);
    return secp256k1_ec_privkey_tweak_add(secp256k1_ctx, (unsigned char*)private_key, (const unsigned char*)tweak);
}

bool ecc_public_key_tweak_add(uint8_t* public_key_inout, const uint8_t* tweak) {
    size_t out;
    secp256k1_pubkey pubkey;
    assert(secp256k1_ctx);
    if (!secp256k1_ec_pubkey_parse(secp256k1_ctx, &pubkey, public_key_inout, 33))
        return false;
    if (!secp256k1_ec_pubkey_tweak_add(secp256k1_ctx, &pubkey, (const unsigned char*)tweak))
        return false;
    if (!secp256k1_ec_pubkey_serialize(secp256k1_ctx, public_key_inout, &out, &pubkey, SECP256K1_EC_COMPRESSED))
        return false;
    return true;
}

bool ecc_verify_privatekey(const uint8_t* private_key) {
    assert(secp256k1_ctx);
    return secp256k1_ec_seckey_verify(secp256k1_ctx, (const unsigned char*)private_key);
}

bool ecc_verify_pubkey(const uint8_t* public_key, bool compressed) {
    secp256k1_pubkey pubkey;
    assert(secp256k1_ctx);
    if (!secp256k1_ec_pubkey_parse(secp256k1_ctx, &pubkey, public_key, compressed ? 33 : 65)) {
        memset(&pubkey, 0, sizeof(pubkey));
        return false;
    }
    memset(&pubkey, 0, sizeof(pubkey));
    return true;
}

bool ecc_sign(const uint8_t* private_key, const uint8_t* hash, uint8_t* signature, size_t* signatureLen) {
    assert(secp256k1_ctx);
    secp256k1_ecdsa_signature sig;
    if (!secp256k1_ecdsa_sign(secp256k1_ctx, &sig, hash, private_key, nullptr, nullptr))
        return false;
    if (!secp256k1_ecdsa_signature_serialize_der(secp256k1_ctx, signature, signatureLen, &sig))
        return false;
    return true;
}

bool ecc_verify_sig(const uint8_t* public_key, bool compressed, const uint8_t* hash, uint8_t* signature, size_t signatureLen) {
    assert(secp256k1_ctx);
    secp256k1_ecdsa_signature sig;
    secp256k1_pubkey pubkey;
    if (!secp256k1_ec_pubkey_parse(secp256k1_ctx, &pubkey, public_key, compressed ? 33 : 65)) {
        return false;
    }
    if (!secp256k1_ecdsa_signature_parse_der(secp256k1_ctx, &sig, signature, signatureLen)) {
        return false;
    }
    return secp256k1_ecdsa_verify(secp256k1_ctx, &sig, hash, &pubkey);
}

bool ecc_sign_recovery(const uint8_t* private_key, const uint8_t* hash, uint8_t* output64, int* v) {
    assert(secp256k1_ctx);
    secp256k1_ecdsa_recoverable_signature sig;
    if (!secp256k1_ecdsa_sign_recoverable(secp256k1_ctx, &sig, hash, private_key, nullptr, nullptr)) {
        return false;
    }
    if (!secp256k1_ecdsa_recoverable_signature_serialize_compact(secp256k1_ctx, output64, v, &sig)) {
        return false;
    }
    return true;
}

bool ecc_recover(const uint8_t* hash, secp256k1_ecdsa_recoverable_signature *sig, int v, uint8_t *outpubkey, size_t *outlen, bool compressed) {
    assert(secp256k1_ctx);
    secp256k1_pubkey pubkey;
    if(!secp256k1_ecdsa_recover(secp256k1_ctx, &pubkey, sig, hash)) {
        return false;
    }
    if (!secp256k1_ec_pubkey_serialize(secp256k1_ctx, outpubkey, outlen, &pubkey, compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED)) {
        return false;
    }
    return true;
}

bool ecc_verify_sig_recovery(const uint8_t* hash, const uint8_t* signature, int v, uint8_t* public_key, size_t *pubkey_len, bool *compressed) {
    assert(secp256k1_ctx);
    *compressed = (v & 4) != 0;
    secp256k1_ecdsa_recoverable_signature sig;
    if (!secp256k1_ecdsa_recoverable_signature_parse_compact(secp256k1_ctx, &sig, signature, v)) {
        return false;
    }
    if(!ecc_recover(hash, &sig, v, public_key, pubkey_len, *compressed)) {
        return false;
    }
    printf("ok");
    return true;
}

