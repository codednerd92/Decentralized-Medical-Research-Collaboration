import { describe, it, expect } from "vitest"
import { mockBlockchain, mockPrincipal } from "./test-utils"

describe("Intellectual Property Contract", () => {
  it("should register IP", () => {
    const admin = mockPrincipal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM")
    const institution = mockPrincipal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG")
    
    mockBlockchain.setTxSender(admin)
    mockBlockchain.callPublic("intellectual-property", "verify-institution", [institution])
    mockBlockchain.callPublic("intellectual-property", "register-project", [0])
    
    mockBlockchain.setTxSender(institution)
    const result = mockBlockchain.callPublic("intellectual-property", "register-ip", [
      "Novel Cancer Treatment",
      "A new approach to treating specific cancer types",
      "patent",
      0,
    ])
    
    expect(result.success).toBe(true)
  })
})

