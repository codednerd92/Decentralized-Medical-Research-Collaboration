import { describe, it, expect } from "vitest"
import { mockBlockchain, mockPrincipal } from "./test-utils"

describe("Institution Verification Contract", () => {
  it("should verify institutions", () => {
    const admin = mockPrincipal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM")
    const institution = mockPrincipal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG")
    
    mockBlockchain.setTxSender(admin)
    
    const result = mockBlockchain.callPublic("institution-verification", "verify-institution", [
      institution,
      "Research Institute A",
    ])
    
    expect(result.success).toBe(true)
  })
})

