//
//  BinaryData.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/6/6.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#ifndef BinaryData_h
#define BinaryData_h

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>

typedef struct binary_data {
    uint8_t *data;
    int len;
} BinaryData;

BinaryData *empty_binary_data();
BinaryData *new_binary_data(uint8_t *c, uint32_t len, bool copy);
BinaryData *combine_binary_data(BinaryData *d, BinaryData *d1, bool auto_free);
void free_binary_data(BinaryData *d);
bool get_int_value_from_data(uint8_t *data, uint32_t from_bit, uint32_t to_bit, uint64_t *out_value);

#endif /* BinaryData_h */
