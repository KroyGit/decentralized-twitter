// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Twitter{

    struct Tweet{
        uint id;
        address from;
        string content;
        uint createdAt;
    }

    struct Message{
        uint id;
        address from;
        address to;
        string content;
        uint createdAt;
    }

    mapping(uint=>Tweet) tweets;
    mapping(address=>uint[]) public tweetsof;
    mapping (address=>Message[]) conversation;
    mapping (address=>address[]) followers;
    mapping (address=>mapping (address=>bool)) public operators;

    uint nextId;
    uint nextMessageId;


    function tweet(address _from,string memory _content) internal {
        require(msg.sender==_from || operators[_from][msg.sender],'you are not authorised');
        tweets[nextId]=Tweet(nextId,_from,_content,block.timestamp);
        tweetsof[_from].push(nextId);
         nextId++;
    }

    function sendMessage(address _from,address _to, string memory _content) internal{
        require(msg.sender==_from || operators[_from][msg.sender],'you are not authorised');
        conversation[_from].push((Message(nextMessageId,_from,_to,_content,block.timestamp)));

    }

    function tweet(string calldata _content) public{
        tweet(msg.sender,_content);
    }

    function tweetFrom() public{

    }
    function sendMessage(string memory _content,address _to) public{
     sendMessage(msg.sender, _to, _content);
    }

    function sendTweetFrom(address _from,address _to,string memory _content) public {
        sendMessage(_from,_to,_content);
    }

    function follow(address _followed) public {
        followers[msg.sender].push(_followed);
    }
    
    function allow(address _operator) public{
        operators[msg.sender][_operator]=true;
    }
    function disAllow(address _operator) public{
        operators[msg.sender][_operator]=false;
    }

    function getLatestTweet(uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,'not found');
         Tweet[] memory memTweets=new Tweet[](count); //creating an empty array
         uint j;
         for(uint i=nextId-count;i<nextId;i++){
             Tweet storage _tweets=tweets[i];
             memTweets[j]=Tweet(_tweets.id,_tweets.from,_tweets.content,_tweets.createdAt);

         }
         return memTweets;
    }

    function getTweetsOf(address user,uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=tweetsof[user].length,'Tweet not found');
        uint[] storage tweetsId=tweetsof[user];
        Tweet[] memory _tweets=new Tweet[](count);
        uint j;
        for(uint i=tweetsof[user].length-count;i<tweetsof[user].length;i++){
         Tweet storage _tweet=tweets[tweetsId[i]];
         _tweets[j]=Tweet(_tweet.id,_tweet.from,_tweet.content,_tweet.createdAt);
        }
       return _tweets;
    }
}