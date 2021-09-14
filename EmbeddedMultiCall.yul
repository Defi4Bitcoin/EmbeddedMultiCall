///////////// EmbeddedMultiCall //////////
// by Sergio Demian Lerner
// Free software. Use at your own risk. 
//////////////////////////////////////////

object "EmbeddedMultiCall" {
    code {
        // function to allocate RAM. Pointer to free memory in 0x40
        function allocate(size) -> ptr {
            ptr := mload(0x40)
            if iszero(ptr) { ptr := 0x60 }
            mstore(0x40, add(ptr, size))
        }
        let offset :=0
        let memEnd :=0
        let bgas :=gas()
        {
			let csize := datasize("EmbeddedMultiCall")
			let fptr := mload(0x40)
			datacopy(fptr, csize, 0x04) // read size as uint32
			let size :=  mload(fptr)
			size :=shr(224,size)

		
			offset := allocate(size)
			memEnd :=add(offset,size)
		
			// This will turn into a memory->memory copy for Ewasm and
			// a codecopy for EVM
			datacopy(offset, csize, size)
        }
        // totalSize is 0x20 for the block number, 0x20 for the blockhash and 0x20 for the number of calls
        let totalSize :=0x60
        
        // now skip the size
        offset :=add(offset,0x04)
        
        // The first argument from the table is the gas limit per call
        let gasLimitPerCall :=shr(224,mload(offset))
        offset :=add(offset,0x04)
        
        let returnGasUsed :=shr(248,mload(offset))
        offset :=add(offset,0x01)
        
        let outBasePtr :=allocate(0x60)
     
        mstore(outBasePtr,number())    
        mstore(add(outBasePtr,0x20),blockhash(sub(number(),1)))
        let numExecOfs :=add(outBasePtr,0x40)
        let execCount :=0
        
        for { let i := offset } lt(i, memEnd) { } {
            // store command in execCount to save context var 
            {
            let c :=shr(248,mload(i))
            execCount :=or(execCount,shl(32,c))
            }
      
            // avoid creating a new variable and reaching the top of the stack
            if eq(shr(32,execCount),0) {
            //switch shr(248,mload(i)) case 0 {
				i := add(i, 0x01)
				// number of calls
				let adr :=shr(96,mload(i))
				i := add(i, 0x14)
				let dataLen :=shr(224,mload(i))
				i := add(i, 0x04)
				let dataOfs :=i
				i := add(i, dataLen)
				let startGas :=gas()          
				let ret :=call(gasLimitPerCall, adr, 0, dataOfs, dataLen, 0, 0)
				if eq(returnGasUsed,1) {
				  let gasUsed :=sub(startGas,gas())
				  let outGasUsedOfs := allocate(0x04)
				  mstore(outGasUsedOfs,shl(224,gasUsed))
				  totalSize :=add(totalSize,0x04)
				}
				let outRetOffset := allocate(0x01)
				mstore(outRetOffset,shl(248,ret))
			
				let outDataLenOffset := allocate(0x04)
				mstore(outDataLenOffset,shl(224,returndatasize()))
			
				let outDataOffset := allocate(returndatasize())
				returndatacopy(outDataOffset,0,returndatasize())
			
				totalSize :=add(totalSize,0x05)
				totalSize :=add(totalSize,returndatasize())
            }

            if eq(shr(32,execCount),0x01) {
                i := add(i, 0x01)
                let adr :=shr(96,mload(i))
				i := add(i, 0x14)
				let abalance :=balance(adr)
				let outBalOffset := allocate(0x20)
				mstore(outBalOffset,abalance)
	  		    totalSize :=add(totalSize,0x20)
            }
            // Remove command from execCount
            execCount :=and(execCount,0xffffffff)
            execCount :=add(execCount,1)
            
   
            
        }
        mstore(numExecOfs,execCount)
        let outTotalGasUsedOfs := allocate(0x04)
        mstore(outTotalGasUsedOfs,shl(224,sub(bgas,gas())))
        totalSize :=add(totalSize,0x04)
        return(outBasePtr, totalSize)
        
        }
     }
