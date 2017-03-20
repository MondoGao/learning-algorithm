/**
 * @param {number[]} ratings
 * @return {number}
 */
var candy2 = function(ratings) {
  for (let j = 0; j < ratings.length; ++j) {
    for (let i = 0; i < ratings.length - 1; ++i) {
      let child1 = ratings[i]
      let child2 = ratings[i + 1]
      let lowBound1 = ratings[i - 1] || 0
      let lowBound2 = ratings[i + 2] || 0
      if (lowBound1 > child1) {
        lowBound1 = 0
      } else if (lowBound1 == child1) {
        lowBound1--
      }
      if (lowBound2 > child2) {
        lowBound2 = 0
      } else if (lowBound2 == child2) {
        lowBound2--
      }
      let lowBound = lowBound1 > lowBound2 ? lowBound1 : lowBound2

      if (child1 > child2) {
        ratings[i + 1] = lowBound2 + 1
        if (lowBound1 > lowBound2) {
          ratings[i] = lowBound1 + 1
        } else {
          ratings[i] = lowBound2 + 2
        }
      } else if (child1 < child2) {
        ratings[i] = lowBound1 + 1
        if (lowBound1 < lowBound2) {
          ratings[i + 1] = lowBound2 + 1
        } else {
          ratings[i + 1] = lowBound1 + 2
        }
      } else {
        ratings[i + 1] = ratings[i] = lowBound + 1
      }
    }
  }
  console.log(ratings)

  return ratings.reduce((acc, val) => (acc + val), 0)
};

/**
 * @param {number[]} ratings
 * @return {number}
 */
var candy = function(ratings) {

  for (var j = 0; j < ratings.length; ++j) {
    for (var i = 0; i < ratings.length - 1; ++i) {
      var child1 = ratings[i];
      var child2 = ratings[i + 1];
      var lowBound1 = ratings[i - 1] || 0;
      var lowBound2 = ratings[i + 2] || 0;
      if (lowBound1 > child1) {
        lowBound1 = 0;
      } else if (lowBound1 == child1) {
        lowBound1--;
      }
      if (lowBound2 > child2) {
        lowBound2 = 0;
      } else if (lowBound2 == child2) {
        lowBound2--;
      }
      var lowBound = lowBound1 > lowBound2 ? lowBound1 : lowBound2;

      if (child1 > child2) {
        ratings[i + 1] = lowBound2 + 1;
        if (lowBound1 > lowBound2) {
          ratings[i] = lowBound1 + 1;
        } else {
          ratings[i] = lowBound2 + 2;
        }
      } else if (child1 < child2) {
        ratings[i] = lowBound1 + 1;
        if (lowBound1 < lowBound2) {
          ratings[i + 1] = lowBound2 + 1;
        } else {
          ratings[i + 1] = lowBound1 + 2;
        }
      } else {
        ratings[i + 1] = ratings[i] = lowBound + 1;
      }
    }
  }
  console.log(ratings);

  var sum = ratings.reduce(function (acc, val) {
    return acc + val;
  }, 0);

  if (ratings.indexOf(0) >= 0) {
    return sum + ratings.length
  } else
    return sum

};
// let N = 8
// let ratings = [6,4,10,2,1] //[1,4,3,2,1]

// class Child {
// 	constructor (grade) {
// 		this.grade = grade
// 		this.apple = 1
// 	}
// }
//
// let children = ratings.map((grade) => (new Child(grade)))

// function compare(arr) {
// 	if (arr.length <= 1) {
// 		return
// 	}
// 	let mid = Math.floor(arr.length / 2)
// 	compare(arr.slice(0, mid))
// 	compare(arr.slice(mid + 1, arr.length - 1))
// 	if (arr[mid].grade > arr[mid + 1].grade) {
// 		arr[mid].apple++
// 	} else if (arr[mid].grade < arr[mid + 1].grade) {
// 		arr[mid + 1].grade
// 	}
// }

console.log(candy([0]))
