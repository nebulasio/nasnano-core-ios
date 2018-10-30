//
//  gp_secp256k1.h
//  EthTest
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#ifndef gp_secp256k1_h
#define gp_secp256k1_h

void ecc_start(void);

void ecc_stop(void);

bool ecc_get_pubkey(const uint8_t* private_key, uint8_t* public_key, size_t* in_outlen, bool compressed);

bool ecc_private_key_tweak_add(uint8_t* private_key, const uint8_t* tweak);

bool ecc_public_key_tweak_add(uint8_t* public_key_inout, const uint8_t* tweak);

bool ecc_verify_privatekey(const uint8_t* private_key);

bool ecc_verify_pubkey(const uint8_t* public_key, bool compressed);

bool ecc_sign(const uint8_t* private_key, const uint8_t* hash, uint8_t* signature, size_t* signatureLen);

bool ecc_verify_sig(const uint8_t* public_key, bool compressed, const uint8_t* hash, uint8_t* signature, size_t signatureLen);

bool ecc_sign_recovery(const uint8_t* private_key, const uint8_t* hash, uint8_t* output64, int* v);

bool ecc_verify_sig_recovery(const uint8_t* hash, const uint8_t* signature, int v, uint8_t* public_key, size_t *pubkey_len, bool *compressed);

#endif /* gp_secp256k1_h */
