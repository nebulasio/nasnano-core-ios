//
//  BinaryData.c
//  NebWalletCore
//
//  Created by 郭平 on 2018/6/6.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#include "BinaryData.h"

BinaryData *empty_binary_data() {
    BinaryData *d = (BinaryData *)malloc(sizeof(BinaryData));
    d->len = 0;
    d->data = NULL;
    return d;
}

BinaryData *new_binary_data(uint8_t *c, uint32_t len, bool copy) {
    BinaryData *d = (BinaryData *) malloc(sizeof(BinaryData));
    d->len = len;
    if (len > 0) {
        if (copy) {
            d->data = (uint8_t *) malloc(len);
            memcpy(d->data, c, len);
        } else {
            d->data = c;
        }
    } else {
        d->data = NULL;
    }
    return d;
}

BinaryData *combine_binary_data(BinaryData *d, BinaryData *d1, bool auto_free) {
    uint32_t len = d->len + d1->len;
    uint8_t *data = (uint8_t *) malloc(len);
    if (d->len > 0) {
        memcpy(data, d->data, d->len);
    }
    if (d1->len > 0) {
        memcpy(data + d->len, d1->data, d1->len);
    }
    BinaryData *r = new_binary_data(data, len, false);
    if (auto_free) {
        free_binary_data(d);
        free_binary_data(d1);
    }
    return r;
}

void free_binary_data(BinaryData *d) {
    if (d->data) {
        free(d->data);
    }
    free(d);
}

bool get_int_value_from_data(uint8_t *data, uint32_t from_bit, uint32_t to_bit, uint64_t *out_value) {
    if (to_bit < from_bit) {
        return false;
    }
    uint32_t total_len = to_bit - from_bit;
    uint32_t begin = 64 - total_len;
    if (total_len > 64) {
        return false;
    }
    *out_value = 0;
    uint32_t len = 0;
    while (len < total_len) {
        uint32_t index = from_bit / 8;
        uint32_t offset = from_bit % 8;
        uint32_t bit_len = 8 - offset;
        uint32_t bit_space_len = total_len - len;
        uint8_t c = data[index];
        uint32_t data_len = 0;
        if (bit_space_len < bit_len) {
            c >>= (bit_len - bit_space_len);
            c <<= (offset + bit_len - bit_space_len);
            data_len = 8 - offset - (bit_len - bit_space_len);
        } else {
            c <<= offset;
            data_len = 8 - offset;
        }
        uint64_t v1 = c;
        int32_t t = begin + len - 56;
        if (t > 0) {
            v1 >>= t;
        } else {
            v1 <<= -t;
        }
        *out_value = (*out_value) | v1;
        len += data_len;
        from_bit += data_len;
        ++index;
    }
    return true;
}
