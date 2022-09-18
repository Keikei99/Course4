import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
  type Time = Time.Time; // 定义Time类型

  public type Message = { // 定义Message的Record类型，包含text和time两个变量
    text: Text;
    time: Time;
  };

  public type Microblog = actor {
    follow: shared(Principal) -> async (); // 添加关注对象
    follows: shared query () -> async [Principal]; // 返回关注列表
    post: shared (Text) -> async (); // 发布新消息
    posts: shared query (Time) -> async [Message]; // 返回所有发布的消息
    timeline: shared (Time) -> async [Message]; // 返回所有关注对象发布的消息
  };

  stable var followed: List.List<Principal> = List.nil();

  public shared func follow(id: Principal): async () {
    followed := List.push(id, followed);
  };

  public shared query func follows(): async [Principal] {
    List.toArray(followed);
  };

  stable var messages: List.List<Message> = List.nil();

  public shared (msg) func post(text: Text): async () {
    // assert(Principal.toText(msg.caller) == "oeo2i-5hw57-hh6wd-2v376-t4cy6-j6ihw-kc7j5-eksox-t34te-j4p2a-zae");
    var sendmsg: Message = {
      text = text;
      time = Time.now();
    };
    messages := List.push(sendmsg, messages);
  };

  // 返回满足Time>since的元素
  public shared query func posts(since: Time): async [Message] {
    var res: List.List<Message> = List.nil();
    for (msg in Iter.fromList(messages)) {
      if (msg.time >= since) {
        res := List.push(msg, res);
      };
    };
    List.toArray(res);
  };

  // 返回关注列表中Time>since的元素
  public shared func timeline(since: Time): async [Message] {
    var all: List.List<Message> = List.nil();
    for (id in Iter.fromList(followed)) {
      let canister: Microblog = actor(Principal.toText(id));
      let msgs: [Message] = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)) {
        all := List.push(msg, all);
      };
    };
    List.toArray(all);
  };

  // public shared func clearFollow(): async [Principal] {
  //   for (follow in Iter.range(0, (List.size<Principal>(followed)))) {
  //     if (List.isNil<Principal>(followed)) {
  //       var followed: List.List<Principal> = List.pop<Principal>(follow);
  //     };
  //   };
  //   List.toArray(followed);
  // };

  // public shared func clearPost(): async [Message] {
  //   for (post in Iter.range(0, (List.size<Message>(messages)))) {
  //     if (List.isNil<Message>(messages)) {
  //       var messages: List.List<Message> = List.pop<Message>(post);
  //     }  
  //   };
  //   List.toArray(messages);
  // };
}
