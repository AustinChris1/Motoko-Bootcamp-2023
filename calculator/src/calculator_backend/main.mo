import Float "mo:base/Float";
import Debug "mo:base/Debug";

actor calculator {

  // Define counter
  var counter : Float = 0;

  //Addition
  public func add(n : Float) : async Float {
    counter += n;
    return counter;
  };
  //subtraction
  public func sub(n : Float) : async Float {
    counter -= n;
    return counter;
  };

  //multiplication
  public func mul(n : Float) : async Float {
    counter *= n;
    return counter;
  };

  //division
  public func div(n : Float) : async ?Float {
    if (n != 0) {
      counter /= n;
      return ?counter;
    } else {
      // 'null' encodes the division by zero error.
      return null;
    };
  };

  //exponential
  public func power(n : Float) : async Float {
    counter **= n;
    return counter;
  };

  //square root
  public func sqrt() : async Float {
    counter **= 0.5;
    return counter;
  };

  //nth root
  // public func nthroot(n : Float) : async Float {
  //   counter := x ** (1 / n);
  //   return counter;
  // };

  //floor
  public func floor() : async Float {
    counter := Float.floor(counter);
    return counter;
  };

  //Clear/Reset
  public func reset() : async Float {
    counter := 0;
    return counter;
  };

  //Answer
  public query func see() : async Float {
    return counter;
  };

};
