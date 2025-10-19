📜 Fractal-Ownership Smart Contract

Version: 1.0.0
Language: Clarity

Summary: A simple fractal ownership system where digital assets can be infinitely subdivided into fractional shares.

🧩 Overview

The Fractal-Ownership contract models ownership like a fractal structure, allowing assets to be divided into infinitely smaller parts while maintaining traceable ownership records. Each asset begins with a fixed total share supply, and owners can subdivide, transfer, or query their share holdings.

This approach can represent co-ownership of digital art, real estate, tokens, or other assets where fractionalization is useful.

⚙️ Core Concepts

Fractal Asset: A digital item with a finite total number of shares (u1000000 by default).

Fractional Ownership: Each principal (user) can own some portion of an asset's total shares.

Subdivision: Owners can split their shares into smaller subdivisions, conceptually representing deeper fractal layers.

Transferability: Fractional shares can be sent to other principals while maintaining total supply consistency.

📂 Contract Structure
Constants
Constant	Description
contract-owner	Principal who deployed the contract
err-owner-only	Error code u100: unauthorized caller
err-not-authorized	Error code u101: general access error
err-asset-not-found	Error code u102: asset doesn’t exist
err-insufficient-shares	Error code u103: insufficient balance
err-invalid-amount	Error code u104: invalid or zero amount
Data Variables & Maps
Variable / Map	Type	Purpose
next-asset-id	uint	Auto-incrementing ID for new assets
asset-supply	map(uint → uint)	Tracks total shares for each asset
asset-info	map(uint → {name, creator, total-shares})	Metadata for each asset
fractional-ownership	map({asset-id, owner} → uint)	Tracks each owner’s share count
share-subdivisions	map({asset-id, parent-id} → (list 100 uint))	(Reserved) Tracks fractal subdivisions
🚀 Public Functions
create-asset (name (string-ascii 64)) → (response uint uint)

Creates a new fractal asset and assigns all initial shares to the creator.

Preconditions: name must not be empty

Returns: The unique asset-id

subdivide-shares (asset-id uint) (share-amount uint) (num-subdivisions uint) → (response uint uint)

Simulates fractal subdivision by dividing existing shares into smaller portions.

Validates ownership and share sufficiency.

Returns the subdivision size per unit.

transfer-shares (asset-id uint) (amount uint) (recipient principal) → (response bool uint)

Transfers fractional ownership to another user.

Fails if amount ≤ 0 or sender lacks enough shares.

Updates balances atomically for both sender and recipient.

🧠 Read-Only Functions
Function	Description
get-asset-info (asset-id)	Returns asset metadata (name, creator, total shares)
get-ownership-share (asset-id, owner)	Returns how many shares an owner has
get-asset-supply (asset-id)	Returns total supply of shares for an asset
get-ownership-percentage (asset-id, owner)	Returns ownership percentage × 10000 (for precision)
🧪 Example Usage
Create an asset:
(contract-call? .fractal-ownership create-asset "Digital Painting #1")
;; Returns: (ok u1)

Transfer shares:
(contract-call? .fractal-ownership transfer-shares u1 u5000 'ST3ABCD...)
;; Returns: (ok true)

Check ownership percentage:
(contract-call? .fractal-ownership get-ownership-percentage u1 'ST3ABCD...)
;; Returns: e.g. u2500 = 25.00%

🔒 Error Handling
Error	Code	Meaning
err-owner-only	u100	Function restricted to contract owner
err-not-authorized	u101	Caller not permitted
err-asset-not-found	u102	Asset does not exist
err-insufficient-shares	u103	Not enough shares to complete action
err-invalid-amount	u104	Invalid number provided

💡 Future Enhancements

Implement unique subdivision tracking for deeper fractal hierarchies.

Add buy/sell marketplace logic for fractional trading.

Integrate royalty distribution for creators.

Support batch transfers and delegation rights.

📜 License
This contract is released under the MIT License.