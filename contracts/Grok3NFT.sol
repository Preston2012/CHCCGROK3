// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Grok3NFT - Special Thanks
 * @dev A heartfelt thank you to the following for their inspiration, leadership, and support:
 *      - God: For the divine guidance and strength in this endeavor.
 *      - Trump: For bold leadership and unyielding spirit.
 *      - Elon: For pioneering innovation and pushing humanity forward.
 *      - America: For the land of opportunity and freedom that made this possible.
 *      - Hero_Dev: For invaluable technical expertise and dedication.
 *      - Golden X: For unwavering support and golden contributions.
 *      This contract is a tribute to their influence as we build a groundbreaking NFT ecosystem!
 */


import {IERC165, IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Grok3NFT is ERC721Enumerable, Ownable, IERC2981, ReentrancyGuard {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MINT_PRICE = 5 ether; // 5 MATIC
    uint256 public constant MAX_PER_TX = 10;
    uint256 public constant AIRDROP_CAP = 1111;
    uint256 public constant ROYALTY_BASIS_POINTS = 500;

    string public baseURI;
    string public baseExtension = ".json";
    bool public saleActive = false;
    bool public airdropActive = false;

    IERC20 public grok3Token;
    IERC721 public cyberHornets;
    IERC721 public animusNFTs;
    IERC20 public hornetToken;

    mapping(uint256 => uint256) public stakedTimestamp;
    mapping(uint256 => uint256) public traitLevel;
    mapping(uint256 => uint256) public pairedHornet;
    mapping(uint256 => uint256) public pairedAnimus;
    mapping(address => bool) public airdropClaimed;

    uint256 public rewardRate = 10 ether;
    uint256 public boostMultiplier = 15 ether;
    uint256 public quantumRate = 20 ether;
    uint256 public hornetBonus = 1 ether;
    uint256 public upgradeInterval = 90 days;
    uint256 public boostedInterval = 60 days;
    uint256 public animusMintThreshold = 30 days;
    uint256 public constant MAX_LEVEL = 5;
    uint256 public airdropMinted = 0;

    address public royaltyReceiver;

    event NFTStaked(uint256 indexed tokenId, address indexed owner, uint256 hornetId, uint256 animusId);
    event NFTUnstaked(uint256 indexed tokenId, address indexed owner, uint256 hornetId, uint256 animusId);
    event TraitsUpgraded(uint256 indexed tokenId, uint256 newLevel);
    event QuantumFused(uint256 indexed newTokenId, uint256 tokenId1, uint256 tokenId2);
    event AirdropClaimed(address indexed claimant, uint256 amount);
    event BaseURIUpdated(string newBaseURI);
    event RoyaltyReceiverUpdated(address newReceiver);
    event SaleToggled(bool isActive);
    event AirdropToggled(bool isActive);
    event CyberHornetsAddressUpdated(address newAddress);

    constructor(
        string memory _initBaseURI,
        address _grok3Token,
        address _animusNFTs,
        address _hornetToken,
        address _cyberHornets
    ) ERC721("Grok3NFT", "GROK3") Ownable(msg.sender) {
        require(_grok3Token != address(0), "Invalid GROK3 token address");
        require(_cyberHornets != address(0), "Invalid CHCC address");
        require(_animusNFTs != address(0), "Invalid Animus address");
        baseURI = _initBaseURI;
        grok3Token = IERC20(_grok3Token);
        animusNFTs = IERC721(_animusNFTs);
        hornetToken = IERC20(_hornetToken);
        cyberHornets = IERC721(_cyberHornets);
        royaltyReceiver = msg.sender;
    }

    function mint(uint256 _amount) external payable {
        require(saleActive, "Public sale is not active");
        require(_amount <= MAX_PER_TX, "Exceeds maximum per transaction");
        require(totalSupply() + _amount <= MAX_SUPPLY, "Exceeds total supply");
        require(msg.value >= MINT_PRICE * _amount, "Insufficient payment");

        _mintBatch(_amount);
    }

    function _mintBatch(uint256 _amount) internal {
        uint256 startId = totalSupply();
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, startId + i);
        }
    }

    function stake(uint256 _tokenId, uint256 _hornetId, uint256 _animusId) external {
        address _owner = ownerOf(_tokenId);
        require(_owner == msg.sender, "Not the owner of the Grok3NFT");
        require(stakedTimestamp[_tokenId] == 0, "Already staked");

        _checkAuthorized(_owner, msg.sender, _tokenId);
        // require(_checkAuthorized(_owner, msg.sender, _tokenId), "Not approved to transfer");

        stakedTimestamp[_tokenId] = block.timestamp;
        _transfer(msg.sender, address(this), _tokenId);

        if (_hornetId != 0) {
            _pairHornet(_tokenId, _hornetId);
        }
        if (_animusId != 0) {
            _pairAnimus(_tokenId, _animusId);
        }

        emit NFTStaked(_tokenId, msg.sender, _hornetId, _animusId);
    }

    function _pairHornet(uint256 _tokenId, uint256 _hornetId) internal {
        require(_hornetId < 8888, "Invalid Hornet ID");
        require(cyberHornets.ownerOf(_hornetId) == msg.sender, "Not the owner of the Hornet");
        require(cyberHornets.getApproved(_hornetId) == address(this) || 
                cyberHornets.isApprovedForAll(msg.sender, address(this)), "Hornet not approved");

        pairedHornet[_tokenId] = _hornetId;
        cyberHornets.transferFrom(msg.sender, address(this), _hornetId);
    }

    function _pairAnimus(uint256 _tokenId, uint256 _animusId) internal {
        require(animusNFTs.ownerOf(_animusId) == msg.sender, "Not the owner of the Animus");
        require(animusNFTs.getApproved(_animusId) == address(this) || 
                animusNFTs.isApprovedForAll(msg.sender, address(this)), "Animus not approved");

        pairedAnimus[_tokenId] = _animusId;
        animusNFTs.transferFrom(msg.sender, address(this), _animusId);
    }

    function unstake(uint256 _tokenId) external nonReentrant {
        require(stakedTimestamp[_tokenId] != 0, "Not staked");
        require(ownerOf(_tokenId) == address(this), "Not locked");

        uint256 stakedTime = block.timestamp - stakedTimestamp[_tokenId];
        uint256 hornetId = pairedHornet[_tokenId];
        uint256 animusId = pairedAnimus[_tokenId];
        bool isPairedHornet = hornetId != 0;
        bool isPairedAnimus = animusId != 0;
        bool isQuantum = traitLevel[_tokenId] > MAX_LEVEL;
        uint256 interval = (isPairedHornet || isPairedAnimus) ? boostedInterval : upgradeInterval;
        uint256 rate = isQuantum ? quantumRate : (isPairedHornet ? boostMultiplier : rewardRate);
        uint256 upgrades = stakedTime / interval;

        _distributeRewards(_tokenId, stakedTime, rate, isPairedHornet);

        if (upgrades > 0 && traitLevel[_tokenId] < MAX_LEVEL) {
            uint256 newLevel = traitLevel[_tokenId] + upgrades > MAX_LEVEL ? MAX_LEVEL : traitLevel[_tokenId] + upgrades;
            traitLevel[_tokenId] = newLevel;
            emit TraitsUpgraded(_tokenId, newLevel);
        }

        _unpairNFTs(_tokenId, hornetId, animusId);

        stakedTimestamp[_tokenId] = 0;
        _transfer(address(this), msg.sender, _tokenId);
        emit NFTUnstaked(_tokenId, msg.sender, hornetId, animusId);
    }

    function _distributeRewards(uint256 _tokenId, uint256 _stakedTime, uint256 _rate, bool _isPairedHornet) internal {
        uint256 grokReward = (_stakedTime * _rate) / 1 days;
        if (grokReward > 0 && grok3Token.balanceOf(address(this)) >= grokReward) {
            grok3Token.safeTransfer(msg.sender, grokReward);
        }
        if (_isPairedHornet && address(hornetToken) != address(0)) {
            uint256 hornetReward = (_stakedTime * hornetBonus) / 1 days;
            if (hornetReward > 0 && hornetToken.balanceOf(address(this)) >= hornetReward) {
                hornetToken.safeTransfer(msg.sender, hornetReward);
            }
        }
    }

    function _unpairNFTs(uint256 _tokenId, uint256 _hornetId, uint256 _animusId) internal {
        if (_hornetId != 0) {
            cyberHornets.transferFrom(address(this), msg.sender, _hornetId);
            pairedHornet[_tokenId] = 0;
        }
        if (_animusId != 0) {
            animusNFTs.transferFrom(address(this), msg.sender, _animusId);
            pairedAnimus[_tokenId] = 0;
        }
    }

    function claimAirdrop(bool _isHornetHolder, uint256 _tokenId, uint256 _holdings) external nonReentrant {
        require(airdropActive, "Airdrop not active");
        require(!airdropClaimed[msg.sender], "Already claimed");
        require(airdropMinted < AIRDROP_CAP, "Airdrop cap reached");

        _verifyOwnership(_isHornetHolder, _tokenId);

        uint256 reward = _calculateAirdropReward(_holdings);
        uint256 remaining = AIRDROP_CAP - airdropMinted;
        if (reward > remaining) reward = remaining;

        _mintBatch(reward);
        airdropMinted += reward;
        airdropClaimed[msg.sender] = true;
        emit AirdropClaimed(msg.sender, reward);
    }

    function _verifyOwnership(bool _isHornetHolder, uint256 _tokenId) internal view {
        if (_isHornetHolder) {
            require(_tokenId < 8888, "Invalid Hornet ID");
            require(cyberHornets.ownerOf(_tokenId) == msg.sender, "Not the owner of the Hornet");
        } else {
            require(animusNFTs.ownerOf(_tokenId) == msg.sender, "Not the owner of the Animus");
        }
    }

    function _calculateAirdropReward(uint256 _holdings) internal pure returns (uint256) {
        uint256 reward = 1;
        if (_holdings >= 5) {
            reward += _holdings / 5;
            if (reward > 5) reward = 5;
        }
        return reward;
    }

    function claimAnimus(uint256 _tokenId) external {
        require(stakedTimestamp[_tokenId] != 0, "Not staked");
        require(pairedHornet[_tokenId] != 0, "No Hornet paired");
        require(block.timestamp - stakedTimestamp[_tokenId] >= animusMintThreshold, "Stake longer");
        // TODO: Implement cross-chain minting of Animus NFTs on Ethereum
    }

    function fuseNFTs(uint256 _tokenId1, uint256 _tokenId2) external {
        require(ownerOf(_tokenId1) == msg.sender && ownerOf(_tokenId2) == msg.sender, "Not owner");
        require(stakedTimestamp[_tokenId1] == 0 && stakedTimestamp[_tokenId2] == 0, "NFTs staked");
        uint256 newTokenId = totalSupply();

        _burn(_tokenId1);
        _burn(_tokenId2);
        _safeMint(msg.sender, newTokenId);
        traitLevel[newTokenId] = MAX_LEVEL + 1;
        if (block.timestamp % 100 == 0) traitLevel[newTokenId] = MAX_LEVEL + 2;
        emit QuantumFused(newTokenId, _tokenId1, _tokenId2);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address _owner = ownerOf(tokenId);
        require(_owner != address(0), "Token does not exist");

        string memory level = traitLevel[tokenId] > 0 ? string(abi.encodePacked("_level", traitLevel[tokenId].toString())) : "";
        string memory boost = pairedHornet[tokenId] != 0 ? "_hivemind" : "";
        string memory villain = pairedAnimus[tokenId] != 0 ? "_villain" : "";
        string memory quantum = traitLevel[tokenId] > MAX_LEVEL ? "_quantum" : "";
        return string(abi.encodePacked(baseURI, tokenId.toString(), level, boost, villain, quantum, baseExtension));
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        address _owner = ownerOf(_tokenId);
        require(_owner != address(0), "Token does not exist");
        receiver = royaltyReceiver;
        royaltyAmount = (_salePrice * ROYALTY_BASIS_POINTS) / 10000;
    }

    function setRoyaltyReceiver(address _newReceiver) external onlyOwner {
        require(_newReceiver != address(0), "Invalid receiver");
        royaltyReceiver = _newReceiver;
        emit RoyaltyReceiverUpdated(_newReceiver);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
        emit BaseURIUpdated(_newBaseURI);
    }

    function toggleSale() external onlyOwner {
        saleActive = !saleActive;
        emit SaleToggled(saleActive);
    }

    function toggleAirdrop() external onlyOwner {
        airdropActive = !airdropActive;
        emit AirdropToggled(airdropActive);
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function pendingRewards(uint256 _tokenId) public view returns (uint256 grokReward, uint256 hornetReward) {
        if (stakedTimestamp[_tokenId] == 0) return (0, 0);
        uint256 stakedTime = block.timestamp - stakedTimestamp[_tokenId];
        uint256 rate = traitLevel[_tokenId] > MAX_LEVEL ? quantumRate : 
                       (pairedHornet[_tokenId] != 0 ? boostMultiplier : rewardRate);
        grokReward = (stakedTime * rate) / 1 days;
        hornetReward = pairedHornet[_tokenId] != 0 && address(hornetToken) != address(0) ? (stakedTime * hornetBonus) / 1 days : 0;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
