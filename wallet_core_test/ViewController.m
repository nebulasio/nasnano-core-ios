//
//  ViewController.m
//  wallet_core_test
//
//  Created by 郭平 on 2018/10/29.
//  Copyright © 2018 郭平. All rights reserved.
//

#import "ViewController.h"
#import <NebWalletCore/NebWalletCore.h>

#define CHAIN_ID_MAIN_NET 1    // Mainnet ChainId
#define CHAIN_ID_TEST_NET 1001 // Testnet ChainId

#define TEST_PRIVATE_KEY @"75b090e8164c08db49199d9c66320c722251197a5570d8d398fc6a50a59e8b72"
//#define TEST_KEYSTORE @"{\"version\":4,\"id\":\"da10a9bd-0d23-42c9-941d-f3ebd12faf8c\",\"address\":\"n1JUqDNm65tobuGrYm35cMWeo1ENpeph3GM\",\"crypto\":{\"ciphertext\":\"7db0844c5716e9aec117a479e738621b74362ec1b61945b636f3b4ff100ca2d6\",\"cipherparams\":{\"iv\":\"47d431ec993d6eb6af6903a578f9b561\"},\"cipher\":\"aes-128-ctr\",\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"salt\":\"691284cb7649bfbc8233335689ae487449f4b689c1edc38c8aaedfdaff312c68\",\"n\":4096,\"r\":8,\"p\":1},\"mac\":\"d2dc651cb1282d2d8edb482b439f72b5dd32d1c3d9097fbb5f0ae6c6d3d4e992\",\"machash\":\"sha3256\"}}"
//#define TEST_KEYSTORE_PWD @"111111111"

#define TEST_KEYSTORE @"{\"address\":\"n1dWv2avSofSraWpHSt7yqH9kXQm7QhkH4p\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"cipherparams\":{\"iv\":\"a9a91919eb9a6fb56791087ab54bf1b6\"},\"ciphertext\":\"cbe0da2caa10549fa2ef19aca2d336e48597ca32f874766101cf2fda8f2ad75f\",\"kdf\":\"scrypt\",\"kdfparams\":{\"c\":0,\"dklen\":32,\"n\":4096,\"p\":1,\"r\":8,\"salt\":\"a9a91919eb9a6fb56791087ab54bf1b6881c069b153562ceb5a6e1a50fec8673\"},\"mac\":\"175b56eee3327f52116dfa52244e044d06a95c53791e0186ed12e124d8d10c2c\",\"machash\":\"sha3256\"},\"id\":\"06499603-65ca-4e7d-ab38-03083040f7cf\",\"version\":4}"
#define TEST_KEYSTORE_PWD @"llllllll"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建新的钱包
    [self createNewWallet:@"abc123"];

    // 从私钥导入钱包
    [self createWithPrivateKey:TEST_PRIVATE_KEY];

    // 从Keystore导入钱包
    [self createWithKeystore:TEST_KEYSTORE pwd:TEST_KEYSTORE_PWD];

    // 普通交易签名打包
    [self normalTransactionTest];

    // NRC20交易签名打包
    [self nrc20TransactionTest];
    
//    [self testSign];
    
}

- (void)createNewWallet:(NSString *)pwd {
    NSLog(@"=== createNewWallet =================================================================================");
    
    NebAccount *account = [NebAccount new];
    NSLog(@"privateKey: %@", account.privateKey);
    NSLog(@"address: %@", account.address);
    NSLog(@"keystore: %@", [account createNewKeystoreWithPwd:pwd]);
}

- (void)createWithPrivateKey:(NSString *)privateKey {
    NSLog(@"=== createWithPrivateKey =================================================================================");
    
    // 通过 私钥 导入钱包，返回值需要判空。
    NebAccount *account = [[NebAccount alloc] initWithPrivateKey:privateKey];
    if (account) {
        NSLog(@"privateKey: %@", account.privateKey);
        NSLog(@"address: %@", account.address);
        NSString *newKeyStore = [account createNewKeystoreWithPwd:@"abc123"];
        NSLog(@"new keystore: %@", newKeyStore);
    } else {
        NSLog(@"privateKey error: %@", privateKey);
    }
}

- (void)createWithKeystore:(NSString *)keystore pwd:(NSString *)pwd {
    NSLog(@"=== createWithKeystore =================================================================================");
    
    // 通过 keystore 导入钱包，需要处理异常。
    NebAccount *account = nil;
    @try {
        account = [[NebAccount alloc] initWithKeystore:keystore pwd:pwd];
    }
    @catch (NSException *ex) {
        NSLog(@"ex name: %@  reason: %@", ex.name, ex.reason);
    }
    if (account) {
        NSLog(@"privateKey: %@", account.privateKey);
        NSLog(@"address: %@", account.address);
        // createNewKeystoreWithPwd 生成全新的Keystore, 修改密码可以用此操作完成。
        NSString *newKeyStore = [account createNewKeystoreWithPwd:TEST_KEYSTORE_PWD];
        NSLog(@"new keystore: %@", newKeyStore);
    }
}

- (void)normalTransactionTest {
    NSLog(@"=== normalTransactionTest =================================================================================");
    
    NebAccount *account = [[NebAccount alloc] initWithPrivateKey:TEST_PRIVATE_KEY];
    
    NebTransaction *tx = [NebTransaction new];
    tx.chainId = CHAIN_ID_TEST_NET; // 使用测试网
    tx.from = account.address;
    tx.to = account.address;
    tx.value = @"0";  // 转账金额
    tx.data = nil;
    tx.nonce = 1;               // 可以通过 rpc接口 查询(查询结果值+1). wiki: https://github.com/nebulasio/wiki/blob/master/rpc.md#getaccountstate
    tx.gasLimit = @"2000000";   // 可以通过 rpc预估接口预估最小值. wiki: https://github.com/nebulasio/wiki/blob/master/rpc.md#estimategas
    tx.gasPrice = @"1000000";   // 可以通过 rpc接口 查询当前链上gasPrice参考值. wiki: https://github.com/nebulasio/wiki/blob/master/rpc.md#getgasprice
    
    NSString *rawTransaction = [account signTransaction:tx];
    NSLog(@"rawTransaction: %@", rawTransaction);
    // 通过 rpc 接口发送 rawTransaction 广播交易. wiki: https://github.com/nebulasio/wiki/blob/master/rpc.md#sendrawtransaction
}

- (NSString *)nrc20TransactionTest {
    NSLog(@"=== nrc20TransactionTest =================================================================================");
    
    NebAccount *account = [[NebAccount alloc] initWithPrivateKey:TEST_PRIVATE_KEY];
    
    NebCallData *data = [NebCallData new];
    data.Function = @"transfer";
    NSString *to = account.address; // 接收用户的地址, (接收者可以是自己)
    NSString *amount = @"0"; // 转账NRC20代币金额。
    data.Args = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", to, amount];
    
    NebTransaction *tx = [NebTransaction new];
    tx.chainId = CHAIN_ID_TEST_NET; // 使用测试网
    tx.from = account.address;
    tx.to = @"n1rR5uiy4vDUn7TPMAtJ8Y1Eo54K6EYvSJ6"; // NRC20合约地址 (示例中为 Testnet ATP 合约地址)
    tx.value = @"0"; // NRC20转账 value 为0即可
    tx.data = data;
    tx.nonce = 561;
    tx.gasLimit = @"2000000";
    tx.gasPrice = @"1000000";
    
    NSString *rawTransaction = [account signTransaction:tx];
    NSLog(@"rawTransaction: %@", rawTransaction);
    // 通过 rpc 接口发送 rawTransaction 广播交易. wiki: https://github.com/nebulasio/wiki/blob/master/rpc.md#sendrawtransaction
    return rawTransaction;
}


//- (void)testSign {
//    for (int i = 0; i < 100; ++i) {
//        [self send:[self nrc20TransactionTest]];
//    }
//}
//
//- (void)send:(NSString *)rawTransaction {
//    NSURL *url = [NSURL URLWithString:@"http://18.188.27.35:8685/v1/user/rawtransaction"];
//    NSMutableURLRequest *resuest = [NSMutableURLRequest requestWithURL:url];
//    [resuest setHTTPMethod:@"post"];
//    NSData *tempData = [[NSString stringWithFormat:@"{\"data\":\"%@\"}", rawTransaction] dataUsingEncoding:NSUTF8StringEncoding];
//    [resuest setHTTPBody:tempData];
//    NSURLResponse *response = nil;
//    NSError *error;
//    NSData *data = [NSURLConnection sendSynchronousRequest:resuest returningResponse:&response error:&error];
//    NSLog(@"====tx: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//}


@end
