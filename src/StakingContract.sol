// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract StakingContract {
    using SafeTransferLib for ERC20;

    event Stake(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);
    event Distribute(address indexed who, uint256 amount);

    struct StakingRecord {
        uint256 amount;
        uint256 rewardsPerStakedTokenSnapshot;
    }

    ERC20 public immutable token;
    uint256 public rewardsPerStakedToken;
    uint256 public totalStaked;
    mapping(address => StakingRecord) public stakingRecords;

    constructor(ERC20 _token) {
        token = _token;
    }

    function stake(uint256 _tokens) external {
        StakingRecord storage userPosition = stakingRecords[msg.sender];

        require(_tokens > 0, "CANNOT STAKE ZERO TOKENS");
        require(userPosition.amount == 0, "UNSTAKE FIRST");

        token.safeTransferFrom(msg.sender, address(this), _tokens);

        totalStaked += _tokens;

        userPosition.amount = _tokens;
        userPosition.rewardsPerStakedTokenSnapshot = rewardsPerStakedToken;

        emit Stake(msg.sender, _tokens);
    }

    function withdraw() external {
        StakingRecord memory userRecord = stakingRecords[msg.sender];

        require(userRecord.amount > 0, "NO ACTIVE STAKE");

        uint256 userReward = userRecord.amount * (rewardsPerStakedToken - userRecord.rewardsPerStakedTokenSnapshot);

        // Storage Change
        totalStaked -= userRecord.amount;
        delete stakingRecords[msg.sender];

        token.safeTransfer(msg.sender, userRecord.amount + userReward);

        emit Withdraw(msg.sender, userRecord.amount + userReward);
    }

    function distribute(uint256 _reward) external {
        require(totalStaked > 0, "CANNOT DISTRIBUTE IF NO ONE IS STAKING");

        token.safeTransferFrom(msg.sender, address(this), _reward);

        rewardsPerStakedToken = rewardsPerStakedToken + (_reward / totalStaked);

        emit Distribute(msg.sender, _reward);
    }
}
