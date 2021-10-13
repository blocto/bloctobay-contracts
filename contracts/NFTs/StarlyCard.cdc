import NonFungibleToken from "../NonFungibleToken.cdc"

// StarlyCard
// NFT cards for Starly!
//
pub contract StarlyCard: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, starlyID: String)
    pub event Burned(id: UInt64, starlyID: String)
    pub event MinterCreated()

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let AdminStoragePath: StoragePath
    pub let MinterStoragePath: StoragePath
    pub let MinterProxyStoragePath: StoragePath
    pub let MinterProxyPublicPath: PublicPath

    // totalSupply
    // The total number of StarlyCard that have been minted
    //
    pub var totalSupply: UInt64

    // NFT
    // A Starly Card as an NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub let starlyID: String

        // initializer
        init(initID: UInt64, initStarlyID: String) {
            self.id = initID
            self.starlyID = initStarlyID
        }

        // destructor
        //
        destroy () {
            emit Burned(id: self.id, starlyID: self.starlyID)
        }
    }

    // This is the interface that users can cast their StarlyCard Collection as
    // to allow others to deposit StarlyCard into their Collection. It also allows for reading
    // the details of StarlyCard in the Collection.
    pub resource interface StarlyCardCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowStarlyCard(id: UInt64): &StarlyCard.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow StarlyCard reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of StarlyCard NFTs owned by an account
    //
    pub resource Collection: StarlyCardCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @StarlyCard.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowStarlyCard
        // Gets a reference to an NFT in the collection as a StarlyCard,
        // exposing all of its fields (including the starlyID).
        // This is safe as there are no functions that can be called on the StarlyCard.
        //
        pub fun borrowStarlyCard(id: UInt64): &StarlyCard.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &StarlyCard.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // fetch
    // Get a reference to a StarlyCard from an account's Collection, if available.
    // If an account does not have a StarlyCard.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &StarlyCard.NFT? {
        let collection = getAccount(from)
            .getCapability(StarlyCard.CollectionPublicPath)!
            .borrow<&StarlyCard.Collection{StarlyCard.StarlyCardCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust StarlyCard.Collection.borowStarlyCard to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowStarlyCard(id: itemID)
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, starlyID: String) {
            emit Minted(id: StarlyCard.totalSupply, starlyID: starlyID)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create StarlyCard.NFT(initID: StarlyCard.totalSupply, initStarlyID: starlyID))

            StarlyCard.totalSupply = StarlyCard.totalSupply + (1 as UInt64)
		}
	}

    pub resource interface MinterProxyPublic {
        pub fun setMinterCapability(capability: Capability<&NFTMinter>)
    }

    // MinterProxy
    //
    // Resource object holding a capability that can be used to mint new NFTs.
    // The resource that this capability represents can be deleted by the admin
    // in order to unilaterally revoke minting capability if needed.
    pub resource MinterProxy: MinterProxyPublic {

        access(self) var minterCapability: Capability<&NFTMinter>?

        pub fun setMinterCapability(capability: Capability<&NFTMinter>) {
            self.minterCapability = capability
        }

        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, starlyID: String) {
            self.minterCapability!
            .borrow()!
            .mintNFT(recipient: recipient, starlyID: starlyID)
        }

        init() {
            self.minterCapability = nil
        }
    }

    // createMinterProxy
    //
    // Function that creates a MinterProxy.
    // Anyone can call this, but the MinterProxy cannot mint without a NFTMinter capability,
    // and only the admin can provide that.
    //
    pub fun createMinterProxy(): @MinterProxy {
        return <- create MinterProxy()
    }

    // Administrator
    //
    // A resource that allows new minters to be created
    pub resource Administrator {

        pub fun createNewMinter(): @NFTMinter {
            emit MinterCreated()
            return <- create NFTMinter()
        }
    }

    // initializer
    //
	init() {
        // Set our named paths
        self.CollectionStoragePath = /storage/starlyCardCollection
        self.CollectionPublicPath = /public/starlyCardCollection
        self.AdminStoragePath = /storage/starlyCardAdmin
        self.MinterStoragePath = /storage/starlyCardMinter
        self.MinterProxyPublicPath = /public/starlyCardMinterProxy
        self.MinterProxyStoragePath = /storage/starlyCardMinterProxy

        // Initialize the total supply
        self.totalSupply = 0

        let admin <- create Administrator()
        let minter <- admin.createNewMinter()
        self.account.save(<-admin, to: self.AdminStoragePath)
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}