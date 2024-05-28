function hostup () {
    docker-compose -f "${FILE_NAME}" up -d
}

function hostdown () {
    docker-compose -f "${FILE_NAME}" down -v
    docker rm $(docker ps -aq);
    docker rmi $(docker images dev-* -q);
}

function networkup () {
    docker exec cli peer channel create -o orderer${ORDERER_NUM}.example.com:${ORDERER_PORT} -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer${ORDERER_NUM}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    sleep 5
    docker exec cli peer channel join -b mychannel.block
    docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp CORE_PEER_ADDRESS=peer1.org1.example.com:8051 -e CORE_PEER_LOCALMSPID="Org1MSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt cli peer channel join -b mychannel.block
    docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${OTHER_ORG}.example.com/users/Admin@org${OTHER_ORG}.example.com/msp -e CORE_PEER_ADDRESS=peer0.org${OTHER_ORG}.example.com:${OTHER_PORT} -e CORE_PEER_LOCALMSPID="Org${OTHER_ORG}MSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${OTHER_ORG}.example.com/peers/peer0.org${OTHER_ORG}.example.com/tls/ca.crt cli peer channel join -b mychannel.block
    docker exec cli peer channel update -o orderer${ORDERER_NUM}.example.com:${ORDERER_PORT} -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer${ORDERER_NUM}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${OTHER_ORG}.example.com/users/Admin@org${OTHER_ORG}.example.com/msp -e CORE_PEER_ADDRESS=peer0.org${OTHER_ORG}.example.com:${OTHER_PORT} -e CORE_PEER_LOCALMSPID="Org${OTHER_ORG}MSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${OTHER_ORG}.example.com/peers/peer0.org${OTHER_ORG}.example.com/tls/ca.crt cli peer channel update -o orderer${ORDERER_NUM}.example.com:${ORDERER_PORT} -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer${ORDERER_NUM}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
}

MODE=$1
WHICH=$2
FILE_NAME="host${WHICH}.yaml"

if [ "${WHICH}" == "1" ]; then
    export ORDERER_NUM=""
    export ORDERER_PORT="7050"
    export OTHER_ORG="2"
    export OTHER_PORT="9051"
elif [ "${WHICH}" == "2" ]; then
    export ORDERER_NUM="2"
    export ORDERER_PORT="8050"
    export OTHER_ORG="1"
    export OTHER_PORT="8051"
fi

if [ "${MODE}" == "hostup" ]; then
    hostup
elif [ "${MODE}" == "hostdown" ]; then
    hostdown
elif [ "${MODE}" == "networkup" ]; then
    networkup
fi
