//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Address.sol";

interface IStaking{
    function _addressToStakedAmount(address validator) external view returns(uint256);
}

contract StakingReward{

    using Address for address;

    address payable public stakingContractAddress;

    uint256 public constant ELIGIBLE_STAKE_AMOUNT = 10000 ether;
    uint256 private startTime;
    uint256 private openTime;
    uint256 public createFirstSlot = 100000000 ether;
    uint256 public createPerSlot = 200000 ether;
    uint256 public totalStakedAmount;
    
    mapping(address => uint256) public addressRewardStakeAmount;
    mapping(address => uint256) public addressRegisterFrom;
    mapping(uint256 => uint256) public feeRewardBalance;
    mapping(address => mapping(uint256 => bool)) public addressIsClaimed;

    event RewardClaimed(address indexed validator, uint256 day, uint256 amount);

    modifier onlyEOA() {
        require(!msg.sender.isContract(), "Only Reward contract can call function");
        _;
    }

    constructor (address payable _contractAddress){
        stakingContractAddress = _contractAddress;
        openTime = block.number + 43200; // 1 day from genesis block
        startTime = openTime + 1296000; // 30 days from opentime
    }

    receive() external payable{
        _addBalanceFromFee();
    }

    function _addBalanceFromFee()public payable{
        feeRewardBalance[currentSlot()] += msg.value;
    }

    function _addRewardBalance()public payable{
    }

    function registerRewardProgram() public onlyEOA{
        require(IStaking(stakingContractAddress)._addressToStakedAmount(msg.sender) >= ELIGIBLE_STAKE_AMOUNT , "User not eligible to register");
        uint256 staked = IStaking(stakingContractAddress)._addressToStakedAmount(msg.sender);
        addressRewardStakeAmount[msg.sender] = staked;
        totalStakedAmount += staked;
        addressRegisterFrom[msg.sender] = currentSlot();
    }

    function claimReward(uint256 slot) public onlyEOA{
        _claimReward(slot);
    }

    function _claimReward(uint256 _slot) private {
        require(_slot < currentSlot(), "User can't claim reward as current or upcoming reward days");
        require(_slot >= addressRegisterFrom[msg.sender], "User didn't stake from this day");
        require(addressRewardStakeAmount[msg.sender] != 0, "User unstaked or didn't staked");
        require(IStaking(stakingContractAddress)._addressToStakedAmount(msg.sender) >= ELIGIBLE_STAKE_AMOUNT , "User not eligible to claim rewards ");
        require(IStaking(stakingContractAddress)._addressToStakedAmount(msg.sender) == addressRewardStakeAmount[msg.sender], "User staked amount is differ");

        if(addressIsClaimed[msg.sender][_slot] == false){
            uint128 userTotalStaked = uint128(addressRewardStakeAmount[msg.sender]);
            uint128 amount = uint128(createOnSlot(_slot)) + uint128(feeRewardBalance[_slot]);
            uint128 price = amount / uint128(totalStakedAmount);
            uint128 reward = userTotalStaked * price;
            addressIsClaimed[msg.sender][_slot] = true;
            payable(msg.sender).transfer(uint256(reward));
            emit RewardClaimed(msg.sender, _slot, reward);
        }
    }

    function blocks() internal returns (uint){
        return block.number;
    }

    function currentSlot() internal returns (uint){
        return blockFor(blocks());
    }

    function blockFor(uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 43200;
    }

    function createOnSlot(uint _slot) internal returns (uint) {
        return _slot == 0 ? createFirstSlot : createPerSlot;
    }
}