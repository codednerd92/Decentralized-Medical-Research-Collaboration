import { describe, it, expect } from "vitest"
import { mockBlockchain, mockPrincipal, mockBufferFromString } from "./test-utils"

describe("Data Sharing Contract", () => {
  it("should share data", () => {
    const admin = mockPrincipal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM")
    const institution = mockPrincipal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG")
    
    mockBlockchain.setTxSender(admin)
    mockBlockchain.callPublic("data-sharing", "verify-institution", [institution])
    
    mockBlockchain.setTxSender(institution)
    const dataHash = mockBufferFromString("sample-data-hash")
    const accessList = []
    
    const result = mockBlockchain.callPublic("data-sharing", "share-data", [
      "Cancer Research Data",
      dataHash,
      accessList,
    ])
    
    expect(result.success).toBe(true)
  })
})

