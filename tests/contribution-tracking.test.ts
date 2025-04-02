import { describe, it, expect } from "vitest"
import { mockBlockchain, mockPrincipal } from "./test-utils"

describe("Contribution Tracking Contract", () => {
  it("should create projects", () => {
    const admin = mockPrincipal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM")
    const institution = mockPrincipal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG")
    
    mockBlockchain.setTxSender(admin)
    mockBlockchain.callPublic("contribution-tracking", "verify-institution", [institution])
    
    mockBlockchain.setTxSender(institution)
    const result = mockBlockchain.callPublic("contribution-tracking", "create-project", ["Cancer Research Project"])
    
    expect(result.success).toBe(true)
  })
})

