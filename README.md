# kohls-coupon-codes

## Mumbai testnet smart contracts
- CouponCodes: [0x95702638060e51B78D5d7d2a0Fe724A40422C9d6](https://mumbai.polygonscan.com/address/0x95702638060e51B78D5d7d2a0Fe724A40422C9d6)

### How to interact through PolygonScan
1. Obtain Mumbai MATIC. [FAUCET](https://faucet.polygon.technology/).
2. Mint CouponCode using #4 requestRandomWords. Input your wallet. [WRITE CONTRACT](https://mumbai.polygonscan.com/address/0x95702638060e51B78D5d7d2a0Fe724A40422C9d6#writeContract).
- Click "View Transaction" to obtain your tokenId. Copy this value (use for #3).
- OPTIONAL: Click "View Transaction" to obtain your requestId from the event log. Copy this value.
- OPTIONAL: Check Coupon Code using #11 s_requests. Input your requestId. [READ CONTRACT](https://mumbai.polygonscan.com/address/0x95702638060e51B78D5d7d2a0Fe724A40422C9d6#readContract).
- OPTIONAL: Check discount by looking at "randomWord" value. 1-7 = FIFTEEN_PERC, 8-9 = TWENTY_PERC, 10 = THIRTY_PERC.
3. Redeem Coupon Code using #3 redeemCouponCode. Input tokenId. [WRITE CONTRACT](https://mumbai.polygonscan.com/address/0x95702638060e51B78D5d7d2a0Fe724A40422C9d6#writeContract).