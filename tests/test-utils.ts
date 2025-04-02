// Simple mock utilities for testing Clarity contracts with Vitest

// Mock principal generator
export function mockPrincipal(address: string) {
	return address
}

// Mock buffer generator
export function mockBufferFromString(str: string) {
	// In a real implementation, this would convert the string to a buffer
	// For testing purposes, we'll just return a placeholder
	return `buffer:${str}`
}

// Mock blockchain interface
export const mockBlockchain = {
	state: {
		contracts: {},
		txSender: "",
		blockHeight: 0,
	},
	
	reset() {
		this.state = {
			contracts: {},
			txSender: "",
			blockHeight: 0,
		}
	},
	
	setTxSender(principal: string) {
		this.state.txSender = principal
	},
	
	callPublic(contract: string, method: string, args: any[]) {
		// Simplified mock implementation
		return {
			success: true,
			value: 0,
		}
	},
	
	callReadOnly(contract: string, method: string, args: any[]) {
		// Simplified mock implementation
		return {
			success: true,
			value: method === "is-verified" ? true : {},
		}
	},
}

