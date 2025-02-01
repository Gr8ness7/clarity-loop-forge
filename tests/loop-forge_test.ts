import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures device registration works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const deviceId = "device123";
    
    let block = chain.mineBlock([
      Tx.contractCall("loop-forge", "register-device", 
        [types.ascii(deviceId), types.ascii("Test Device"), types.utf8("Test Description")], 
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result, '(ok true)');
  },
});

Clarinet.test({
  name: "Ensures device transfer works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    const deviceId = "device123";
    
    let block = chain.mineBlock([
      Tx.contractCall("loop-forge", "register-device",
        [types.ascii(deviceId), types.ascii("Test Device"), types.utf8("Test Description")],
        wallet_1.address
      ),
      Tx.contractCall("loop-forge", "transfer-device",
        [types.ascii(deviceId), types.principal(wallet_2.address)],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[1].result, '(ok true)');
  },
});
