/**
 * @param {number[]} nums
 * @return {number}
 */
var firstMissingPositive = function(nums) {
  if(nums.length < 1) {
    return 1
  } else if(nums.length < 2) {
    return nums[0] == 1 ? 2 : 1
  }
  
  var flagArr = new Array(nums.length);
  var negativeNum = 0;
  for(var i = 0; i < nums.length; i++) {
    if (nums[i] > flagArr.length){
      flagArr.length = nums[i];
    }
    flagArr[nums[i] - 1] = 1;
  }
  for(var i = 0; i < flagArr.length; i++) {
    if (!flagArr[i]) {
      return i + 1
    }
  }
  return flagArr.length + 1
};
